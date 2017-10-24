defmodule KumaServer.Module do
  defmacro __using__(_opts) do
    quote do
      import KumaServer.Module
    end
  end

  defmacro match(text, do: body) when is_bitstring(text) do    
    quote do
      defp match(var!(data)) when is_match(unquote(text), var!(data)) do
        unquote(body)
      end
    end
  end

  defmacro match(text, func) when is_bitstring(text) when is_atom(func) do
    quote do
      if Regex.compile!("^(#{unquote(text)})") |> Regex.match?(var!(data).message.text), do: unquote(func)(var!(data))
    end
  end

  defmacro match(texts, do: body) when is_list(texts) do
    quote do
      if Regex.compile!("^(#{unquote(texts) |> Enum.join("|")})") |> Regex.match?(var!(data).message.text), do: unquote(body)
    end
  end

  defmacro match(texts, func) when is_list(texts) when is_atom(func) do
    quote do
      if Regex.compile!("^(#{unquote(texts) |> Enum.join("|")})") |> Regex.match?(var!(data).message.text), do: unquote(func)(var!(data))
    end
  end
end