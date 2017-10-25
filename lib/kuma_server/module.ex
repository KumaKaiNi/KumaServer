defmodule KumaServer.Module do
  @moduledoc """
  Metaprogramming to make things easier and cleaner looking.
  """

  @doc """
  Simply an import for now.
  """
  @spec __using__(map) :: any
  defmacro __using__(_opts) do
    quote do
      import KumaServer.Module
    end
  end

  @doc """
  Regex builder for commands.
  """
  @spec match(String.t) :: boolean
  defmacro match(text) when is_bitstring(text) do
    quote do
      Regex.compile!("^(#{unquote(text)})") 
      |> Regex.match?(var!(data).message.text)
    end
  end


  @doc """
  Regex builder for commands. Takes a list of commands.
  """
  @spec match(list) :: boolean
  defmacro match(texts) when is_list(texts) do
    quote do
      Regex.compile!("^(#{unquote(texts) |> Enum.join("|")})") 
      |> Regex.match?(var!(data).message.text)
    end
  end

  @doc """
  Checks if the user is a moderator.
  """
  @spec is_mod :: boolean
  defmacro is_mod do
    quote do
      var!(data).user.moderator
    end
  end

  @doc """
  Checks if the channel is private.
  """
  @spec is_private :: boolean
  defmacro is_private do
    quote do
      var!(data).channel.private
    end
  end

  @doc """
  Checks if the channel is nsfw.
  """
  @spec is_nsfw :: boolean
  defmacro is_nsfw do
    quote do
      var!(data).channel.nsfw
    end
  end
end