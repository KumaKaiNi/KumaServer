defmodule KumaServerWeb.Router do
  use KumaServerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug :auth
  end

  scope "/api", KumaServerWeb do
    pipe_through :api # Use the default browser stack

    post "/", ApiController, :handle
  end

  def auth(conn, _opts) do
    auth_key = Application.get_env(:kuma_server, :server_auth)
    auth_header = Plug.Conn.get_req_header(conn, "authorization") |> List.first

    cond do
      auth_key == auth_header -> conn
      true -> 
        conn
        |> send_resp(401, "unauthorized")
        |> halt()
    end
  end
end
