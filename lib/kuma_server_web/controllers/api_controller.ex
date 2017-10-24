defmodule KumaServerWeb.ApiController do
  use KumaServerWeb, :controller
  use KumaServer.Module
  import KumaServer.Util

  # curl -XPOST -H 'Content-Type: application/json' -H 'Auth: test' --data-binary '{"message":{"text":"!ping"}}' dev.riichi.me/api
  def handle(conn, params) do
    data = struct(KumaServer.Request, keys_to_atoms(params))

    case data.message do
      nil -> 
        conn
        |> send_resp(400, "bad request")
        |> halt()
      _message ->
        case parse(data) do
          nil ->
            conn
            |> send_resp(204, "")
            |> halt()
          response ->
            conn
            |> json(response)
        end
    end
  end

  def parse(data) do
    cond do
      is_mod() and match "!foo" -> reply %{text: "Bar!"}
      match "!ping" -> reply %{text: "Pong!"}
      true -> nil
    end
  end
end
