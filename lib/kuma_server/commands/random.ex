defmodule KumaServer.Commands.Random do
  import KumaServer.Util
  alias KumaServer.{Request, Response}

  @moduledoc """
  Commands centered around randomness.
  """

  @doc """
  Flips a coin.
  """
  @spec coin_flip :: Response.t
  def coin_flip do
    reply %{text: Enum.random(["Heads.", "Tails."])}
  end

  @doc """
  Picks a random item from a given list.
  """
  @spec pick_from_a_list(Request.t) :: Response.t
  def pick_from_a_list(data) do
    [_ | raw_choices] = data.message.text |> String.split
    choices = for choice <- raw_choices do
      String.replace(choice, "/", "")
    end

    case choices do
      [] -> nil
      choices ->
        choices_list = choices |> Enum.join(" ") |> String.split(", ")
        case length(choices_list) do
          1 -> reply %{text: "What? Okay, #{choices_list |> List.first}, I guess. Didn't really give me a choice there."}
          _ -> reply %{text: "#{choices_list |> Enum.random}"}
        end
    end
  end

  @doc """
  Rolls a d6, or a series of dice if provided.
  """
  @spec roll_dice(Request.t) :: Response.t
  def roll_dice(data) do
    [_ | roll] = data.message.text |> String.split

    case roll do
      [] -> reply %{text: "#{Enum.random(1..6)}"}
      [roll] ->
        [count | amount] = roll |> String.split("d")

        case amount do
          [] ->
            if String.to_integer(count) > 1 do
              reply %{text: "#{Enum.random(1..String.to_integer(count))}"}
            end
          [amount] ->
            if String.to_integer(count) > 1 do
              rolls = for _ <- 1..String.to_integer(count) do
                Enum.random(1..String.to_integer(amount))
              end

              reply %{text: "#{rolls |> Enum.join(", ")}"}
            end
        end
    end
  end

  @doc """
  8-ball prediction
  """
  @spec prediction :: Response.t
  def prediction do
    predictions = [
      "It is certain.",
      "It is decidedly so.",
      "Without a doubt.",
      "Yes, definitely.",
      "You may rely on it.",
      "As I see it, yes.",
      "Most likely.",
      "Outlook good.",
      "Yes.",
      "Signs point to yes.",
      "Reply hazy, try again.",
      "Ask again later.",
      "Better not tell you now.",
      "Cannot predict now.",
      "Concentrate and ask again.",
      "Don't count on it.",
      "My reply is no.",
      "My sources say no.",
      "Outlook not so good.",
      "Very doubtful."
    ]

    reply %{text: Enum.random(predictions)}
  end

  @doc """
  Randomized Dark Souls message
  """
  @spec souls_message :: Response.t
  def souls_message do
    request = "http://souls.riichi.me/api" |> HTTPoison.get!
    response = Poison.Parser.parse!((request.body), keys: :atoms)

    reply %{text: "#{response.message}"}
  end

  @doc """
  Random GDQ message using https://taskinoz.com/gdq/
  """
  @spec gdq :: Response.t
  def gdq do
    request = "https://taskinoz.com/gdq/api/" |> HTTPoison.get!
    reply %{text: "#{request.body}"}
  end
end
