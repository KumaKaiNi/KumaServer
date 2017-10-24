defmodule KumaServerWeb.ApiController do
  use KumaServerWeb, :controller
  use KumaServer.Module
  import KumaServer.Util

  # curl -XPOST -H 'Content-Type: application/json' -H 'Auth: test' --data-binary '{"content": {"message":{"text":"!ping"}}}' dev.riichi.me/api
  def handle(conn, params) do
    data = keys_to_atoms(params)
    json conn, parse(data.content)
  end

  def parse(data) do
    cond do
      match "!foo", do: %{text: "Bar!"}
      match "!ping", do: %{text: "Pong!"}
    end
  end
end
