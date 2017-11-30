defmodule KumaServer.Commands.Markov do
  import KumaServer.Util
  alias KumaServer.Response

  @moduledoc """
  Module for handling markov generation.
  """

  @doc """
  Main command handler.
  """
  @spec generate :: Response.t
  def generate do
    reply %{text: gen_markov("/home/bowan/bots/_log/irc/twitch/rekyuus.log")}
  end
  
  def generate_discord do
    reply %{text: gen_markov("/home/bowan/bots/_log/discord/214268737887404042/galley.log")}
  end

  defp gen_markov(input_file, word_count \\ 0, start_word \\ nil) do
    alias KumaServer.Commands.Markov.{Dictionary, Generator}

    filepath = input_file
    file = File.read!(filepath)

    lines = file |> String.split("\n")
    lines = (for line <- lines do
      case Regex.named_captures(~r/\[.*\] (?<username>.*): (?<capture>.*)/, line) do
        nil -> nil
        %{"username" => username, "capture" => capture} ->
          unless username == "kumakaini" do
            ignore? = capture |> String.split(":") |> List.first

            case ignore? do
              "http" -> nil
              "https" -> nil
              capture -> unless capture |> String.first == "!", do: capture
            end
          end
      end
    end |> Enum.uniq) -- [nil]

    words = lines |> Enum.join(" ")

    markov_length = case word_count do
      0 ->
        average = round(length(words |> String.split) / length(lines))
        average + :rand.uniform(average)
      count -> count
    end

    markov_start = case start_word do
      nil -> lines |> Enum.random |> String.split |> List.first
      start_word -> start_word
    end

    Dictionary.new
    |> Dictionary.parse(lines |> Enum.join("\n"))
    |> Generator.generate_words(markov_start, markov_length)
  end
end