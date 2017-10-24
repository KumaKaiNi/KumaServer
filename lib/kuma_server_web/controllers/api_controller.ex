defmodule KumaServerWeb.ApiController do
  use KumaServerWeb, :controller
  use KumaServer.Module

  # curl -XPOST -H 'Content-Type: application/json' -H 'Auth: test' --data-binary '{"content": {"message":{"text":"!ping"}}}' dev.riichi.me/api
  def handle(conn, params) do
    data = keys_to_atoms(params)
    json conn, match(data.content)
  end

  match "!foo", do: %{text: "Bar!"}
  match "!ping", do: %{text: "Pong!"}

  defp keys_to_atoms(struct) do
    Enum.reduce struct, %{}, fn({key, val}, acc) ->
      cond do
        is_map(val) -> Map.put(acc, String.to_atom(key), keys_to_atoms(val))
        true        -> Map.put(acc, String.to_atom(key), val)
      end
    end
  end
end
