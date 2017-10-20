defmodule KumaServerWeb.Router do
  use KumaServerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug :auth
  end

  scope "/", KumaServerWeb do
    pipe_through :api # Use the default browser stack

    post "/", ApiController, :handle
  end

  def auth(conn, _opts) do
    IO.inspect conn.req_headers
    conn
  end
end
