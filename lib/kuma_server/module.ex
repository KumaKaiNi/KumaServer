defmodule KumaServer.Module do
  defmacro __using__(_opts) do
    quote do
      import KumaServer.Module
    end
  end

  defmacro match(text) when is_bitstring(text) do
    quote do
      Regex.compile!("^(#{unquote(text)})") 
      |> Regex.match?(var!(data).message.text)
    end
  end

  defmacro match(texts) when is_list(texts) do
    quote do
      Regex.compile!("^(#{unquote(texts) |> Enum.join("|")})") 
      |> Regex.match?(var!(data).message.text)
    end
  end

  defmacro is_mod do
    quote do
      var!(data).user.moderator
    end
  end

  defmacro is_private do
    quote do
      var!(data).source.channel.private
    end
  end

  defmacro is_nsfw do
    quote do
      var!(data).source.channel.nsfw
    end
  end
end