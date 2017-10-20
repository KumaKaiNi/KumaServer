defmodule KumaServerWeb.ApiController do
  use KumaServerWeb, :controller

  # curl -XPOST -H 'Content-Type: application/json' --data-binary '{"test":true}' dev.riichi.me
  def handle(conn, params) do
    json conn, %{"kuma" => true}
  end
end
