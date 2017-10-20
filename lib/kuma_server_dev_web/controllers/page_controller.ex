defmodule KumaServerDevWeb.PageController do
  use KumaServerDevWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
