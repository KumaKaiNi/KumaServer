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
    case Plug.Conn.get_req_header(conn, "auth") do
      ["test"] -> conn
      _ -> 
        conn
        |> send_resp(401, "unauthorized")
        |> halt()
    end
  end
end
