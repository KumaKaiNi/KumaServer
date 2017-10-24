defmodule KumaServerWeb.ApiController do
  use KumaServerWeb, :controller
  use KumaServer.Module
  import KumaServer.Util
  alias KumaServer.Commands

  @moduledoc """
  API handler for bot commands.

  Accepts `t:KumaServer.Request.t/0` objects and returns `t:KumaServer.Response.t/0` objects.

  ## Example request

  ```sh
  curl -XPOST \
  -H 'Content-Type: application/json' \
  -H 'Authorization: test' \
  --data-binary '{"message":{"text":"!ping"}, "user":{"moderator": true}}' \
  dev.riichi.me/api
  ```
  """

  @doc """
  The handler for HTTP reponses.

  Returns `400 Bad Request` if there is no message, `204 No Content` if there are no matches, or `200 OK` with a JSON response otherwise.
  """
  @spec handle(Plug.Conn.t, map) :: Plug.Conn.t
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

  @doc """
  Command parser.

  Will return a response if available, with text and/or an image url. Otherwise will return `nil` if nothing matches.
  """
  @spec parse(KumaServer.Request.t) :: KumaServer.Response.t | nil
  def parse(data) do
    cond do
      is_mod() and match ["!command add", "!command edit", "!command set", "!command change"] -> Commands.CustomCommands.custom_command_set(data)
      is_mod() and match ["!command remove", "!command rem", "!command delete", "!command del"] -> Commands.CustomCommands.custom_command_delete(data)
      true -> Commands.CustomCommands.custom_command(data)
    end
  end
end
