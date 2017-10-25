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

  Returns `400 Bad Request` if there is no message, `204 No Content` if there are no matches, or `200 OK` with a JSON response otherwise.
  """
  @spec handle(Plug.Conn.t, map) :: Plug.Conn.t
  def handle(conn, params) do
    data = struct(KumaServer.Request, keys_to_atoms(params))

    case data.message do
      nil -> 
        conn
        |> send_resp(400, "bad request")
        |> halt()
      _message ->
        case parse(data) do
          nil ->
            conn
            |> send_resp(204, "")
            |> halt()
          response ->
            conn
            |> json(response)
        end
    end
  end

  @doc """
  Command parser.

  Will return a response if available, with text and/or an image url. Otherwise will return `nil` if nothing matches.
  """
  @spec parse(KumaServer.Request.t) :: KumaServer.Response.t | nil
  def parse(data) do
    cond do
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
      is_nsfw() and match "!dan" -> Commands.Danbooru.basic(data)
      is_nsfw() and match "!ecchi" -> Commands.Danbooru.questionable(data)
      is_nsfw() and match "!lewd" -> Commands.Danbooru.explicit(data)
      match "!safe" -> Commands.Danbooru.safe(data)
      match "!quote" -> Commands.Quote.get(data)
      true -> Commands.CustomCommand.query(data)
    end
  end
end
