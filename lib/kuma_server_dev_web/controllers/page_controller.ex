defmodule KumaServerDevWeb.PageController do
  use KumaServerDevWeb, :controller

  def index(conn, _params) do
    json conn, %{"kuma" => true}
  end
end
