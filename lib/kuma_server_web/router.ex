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
    IO.inspect Plug.Conn.get_req_header(conn, "auth")
    
    case Plug.Conn.get_req_header(conn, "auth") do
      nil -> unauthorized(conn)
      auth -> case auth do
        "test" -> conn
        _ -> unauthorized(conn)
      end
    end
  end

  def unauthorized(conn) do
    conn
    |> send_resp(401, "unauthorized")
    |> halt()
  end
end
