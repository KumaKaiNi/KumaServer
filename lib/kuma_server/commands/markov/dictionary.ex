defmodule KumaServer.Commands.Markov.Dictionary do
  def new do
    Keyword.new
  end

  def parse(dictionary, source) when is_binary(source) do
    parse(dictionary, String.split(source))
  end

  def parse(dictionary, [word1, word2 | rest]) do
    value = Keyword.get(dictionary, word1, [])
    dictionary = Keyword.put(dictionary, word1, [word2 | value])
    parse(dictionary, [word2 | rest])
  end

  def parse(dictionary, [_single]), do: dictionary

  def next(dictionary, word), do: Keyword.get(dictionary, word)
end