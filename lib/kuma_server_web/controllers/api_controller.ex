defmodule KumaServerWeb.ApiController do
  use KumaServerWeb, :controller
  use KumaServer.Module

  # curl -XPOST -H 'Content-Type: application/json' -H 'Auth: test' --data-binary '{"content": {"message":{"text":"!ping"}}}' dev.riichi.me
  def handle(conn, params) do
    data = for {key, val} <- params, into: %{}, do
      {String.to_atom(key), val}
    end

    json conn, parse(data.content)
  end

  defp parse(data) do
    match "!ping", do: %{text: "Pong!"}
    match "!foo", do: %{text: "Bar!"}
  end
end
