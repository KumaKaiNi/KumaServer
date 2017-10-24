defmodule KumaServerWeb.ApiController do
  use KumaServerWeb, :controller
  use KumaServer.Module

  # curl -XPOST -H 'Content-Type: application/json' -H 'Auth: test' --data-binary '{"content": {"message":{"text":"!ping"}}}' dev.riichi.me/api
  def handle(conn, params) do
    data = atomize_map(params)    
    json conn, parse(data.content)
  end

  defp parse(data) do
    match "!ping", do: %{text: "Pong!"}
    match "!foo", do: %{text: "Bar!"}
  end

  defp atomize_map(struct) do
    struct |> Enum.reduce %{}, fn({key, val}, acc) ->
      cond do
        is_map(val) -> Map.put(acc, String.to_atom(key), atomize_map(val))
        true        -> Map.put(acc, String.to_atom(key), val)
      end
    end
  end
end
