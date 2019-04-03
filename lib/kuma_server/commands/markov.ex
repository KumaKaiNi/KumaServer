defmodule KumaServer.Commands.Markov do
  import KumaServer.Util
  alias KumaServer.Response

  @moduledoc """
  Module for handling markov generation.
  """

  @doc """
  Parses a split file of lines and creates a Markov dictionary.
  """
  def parse(lines) when is_list(lines) do
    words = lines |> Enum.join(" \n ") |> String.split(" ")

    [word1, word2 | remain] = words
    dictionary = Map.put(%{}, word1, [word2])
    parse(dictionary, remain)
  end

  def parse(dictionary, [word1, word2 | remain]) do
    case word1 do
      "\n" -> parse(dictionary, [word2] ++ remain)
      word1 ->
        words = Map.get(dictionary, word1, [])
        dictionary = Map.put(dictionary, word1, words ++ [word2])

        parse(dictionary, [word2] ++ remain)
    end
  end

  def parse(dictionary, [_remain]), do: dictionary
  def parse(dictionary, []), do: dictionary

  @doc """
  Generates Markov chains with provided dictionary and starting word.
  """
  def generate(dictionary, word) do
    next_possible_words = delete_all(dictionary[word], "\n")

    case next_possible_words do
      [] -> word
      next_possible_words ->
        next_word = Enum.random(next_possible_words)
        current_string = [word, next_word]

        generate(dictionary, current_string, next_word)
    end
  end

  def generate(dictionary, current_string, word) do
    next_possible_words = dictionary[word]
    next_word = Enum.random(next_possible_words)

    case next_word do
      "\n" -> current_string |> Enum.join(" ")
      next_word ->
        current_string = current_string ++ [next_word]
        generate(dictionary, current_string, next_word)
    end
  end

  @doc """
  Finds a good starting word, or tries to.
  """
  def get_start_word(dictionary, lines) do
    start_word = lines |> Enum.random |> String.split |> List.first
    next_possible_words = delete_all(dictionary[start_word], "\n")

    case next_possible_words do
      nil -> get_start_word(dictionary, lines)
      _next_possible_words -> start_word
    end
  end

  @doc """
  Creates a Markov chain from the provided lines.
  """
  def create_markov(lines) do
    dictionary = parse(lines)
    start_word = get_start_word(dictionary, lines)

    generate(dictionary, start_word)
  end

  @doc """
  Main command handler.
  """
  def markov do
    reply %{text: gen_markov("/home/bowan/bots/_log/irc/twitch/rekyuus.log")}
  end
  
  def markov_discord do
    reply %{text: gen_markov("/home/bowan/bots/_log/discord/214268737887404042/214268737887404042.log")}
  end

  defp gen_markov(input_file) do
    file = File.read!(input_file)

    lines = file |> String.split("\n") |> Enum.take(-10_000)
    lines = (for line <- lines do
      case Regex.named_captures(~r/\[.*\] (?<user>.*): (?<msg>.*)/, line) do
        nil -> nil
        %{"user" => user, "msg" => msg} ->
          cond do
            # Ignore messages from Kuma
            user == "+kumakaini" -> nil
            # Ignore messages with URLS in them
            Regex.match?(~r/.*((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?).*/, msg) -> nil
            # Ignore bot commands
            Regex.match?(~r/^\![A-Za-z].+/, msg) -> nil
            true -> 
              for word <- String.split(msg) do
                cond do
                  # Replaces Discord emote strings to text counterparts
                  Regex.match?(~r/<:.+:\d{18}>/, word) ->
                    cap = Regex.named_captures(~r/<:(?<emote>.+):\d{18}>/, word)
                    cap["emote"]
                  true -> word
                end
              end |> Enum.join(" ")
          end
      end
    end |> delete_all(nil)

    create_markov(lines)
  end
end