defmodule KumaServerWeb.ApiController do
  use KumaServerWeb, :controller
  use KumaServer.Module
  import KumaServer.Util
  alias KumaServer.{Commands, Request, Response}

  @moduledoc """
  API handler for bot commands.

  Accepts `t:KumaServer.Request.t/0` objects and returns `t:KumaServer.Response.t/0` objects.

  ## Example request

  ```sh
  curl -XPOST \
  -H 'Content-Type: application/json' \
  -H 'Authorization: test' \
  --data-binary '{"message":{"text":"!ping"}, "user":{"moderator": true}}' \
  dev.riichi.me/api
  ```
  """

  @doc """
  The handler for HTTP reponses.

  Returns `400 Bad Request` if there is invalid content in the parameters, `204 No Content` if there are no matches, or `200 OK` with a JSON response otherwise.
  """
  @spec handle(Plug.Conn.t, map) :: Plug.Conn.t
  def handle(conn, params) do
    data = struct(Request, keys_to_atoms(params))

    try do
      case parse(data) do
        nil ->
          conn
          |> send_resp(204, "")
          |> halt()
        response ->
          conn
          |> json(response)
      end    
    rescue
      error ->
        IO.inspect error, label: "error"

        conn
        |> send_resp(500, "internal server error")
        |> halt()
    end
  end

  @doc """
  Command parser.

  Will return a response if available, with text and/or an image url. Otherwise will return `nil` if nothing matches.
  """
  @spec parse(Request.t) :: Response.t | nil
  def parse(data) do
    KumaServer.Logger.log(:recv, data)

    response_data = cond do
      is_mod() and match [
        "!command add",
        "!command edit",
        "!command set",
        "!command change"
      ] -> Commands.CustomCommand.set(data)
      is_mod() and match [
        "!command remove",
        "!command rem",
        "!command delete",
        "!command del"
      ] -> Commands.CustomCommand.delete(data)
      is_mod() and match [
        "!quote add",
        "!quote set"
      ] -> Commands.Quote.add(data)
      is_mod() and match [
        "!quote delete",
        "!quote del",
        "!quote remove",
        "!quote rem"
      ] -> Commands.Quote.delete(data)

      is_nsfw() and match "!dan"   -> Commands.Danbooru.basic(data)
      is_nsfw() and match "!ecchi" -> Commands.Danbooru.questionable(data)
      is_nsfw() and match "!lewd"  -> Commands.Danbooru.explicit(data)
      is_nsfw() and match [
        "!nhen",
        "!nhentai",
        "!doujin"
      ] -> Commands.Lewd.nhentai(data)

      is_private() and match "!coins"  -> Commands.RPG.Bank.coins(data)
      is_private() and match "!slots"  -> Commands.RPG.Casino.slots(data)
      is_private() and match "!level"  -> Commands.RPG.Stats.level_up(data)
      is_private() and match "!respec" -> Commands.RPG.Stats.respec(data)

      match "!safe"     -> Commands.Danbooru.safe(data)
      match "!help"     -> Commands.General.help
      match "!kuma"     -> Commands.General.ping
      match "!smug"     -> Commands.Image.smug
      match "!markov"   -> Commands.Markov.generate
      match "!quote"    -> Commands.Quote.get(data)
      match [
        "!coin$",
        "!flip"
      ] -> Commands.Random.coin_flip
      match "!guidance" -> Commands.Random.souls_message
      match [
        "!pick",
        "!choose"
      ] -> Commands.Random.pick_from_a_list(data)
      match "!predict"  -> Commands.Random.prediction
      match "!roll"     -> Commands.Random.roll_dice(data)
      match "!top5"     -> Commands.RPG.leaderboard(data)
      match "!jackpot"  -> Commands.RPG.Casino.jackpot
      match "!stats"    -> Commands.RPG.Stats.user_stats(data)
      match "!np"       -> Commands.Stream.now_playing
      match "!time"     -> Commands.Stream.local_time
      match "!uptime"   -> Commands.Stream.uptime

      match [
        "ty kuma",
        "thanks kuma",
        "thank you kuma"
      ] -> Commands.General.thanks
      match [
        "hi$",
        "hello$",
        "hey$",
        "sup$",
        "hi everyone"
      ] -> Commands.General.hello
      match "(S|s)(A|a)(M|m)(E|e)" -> Commands.General.same

      true -> Commands.CustomCommand.query(data)
    end

    case response_data do
      nil -> nil
      response_data -> 
        case response_data.response do
          %{text: text, image: image} -> 
            KumaServer.Logger.log(:send, data, "#{image.source} #{text}")
          %{text: text} -> 
            KumaServer.Logger.log(:send, data, text)
        end        
    end

    response_data
  end
end
