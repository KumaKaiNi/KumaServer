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
end