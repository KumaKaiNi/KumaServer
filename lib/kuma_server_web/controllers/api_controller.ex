defmodule KumaServerWeb.ApiController do
  use KumaServerWeb, :controller
  use KumaServer.Module
  import KumaServer.Util

  # curl -XPOST -H 'Content-Type: application/json' -H 'Auth: test' --data-binary '{"message":{"text":"!ping"}}' dev.riichi.me/api
  def handle(conn, params) do
    data = struct(KumaServer.Request, keys_to_atoms(params))

    case data.message.text do
      nil -> 
        conn
        |> send_resp(400, "bad request")
        |> halt()
      data ->
        conn
        |> json(parse(data))
    end
  end

  def parse(data) do
    cond do
      is_mod() and match "!foo" -> %{text: "Bar!"}
      match "!ping" -> %{text: "Pong!"}
      true          -> nil
    end
  end
end
