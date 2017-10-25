defmodule KumaServer.Commands.General do
  import KumaServer.Util
  alias KumaServer.{Request, Response}
  
  @moduledoc """
  General commands.
  """
  
  @doc """
  Returns a link with command listing.
  """
  @spec help :: Response.t
  def help do
    reply %{text: "https://github.com/KumaKaiNi/KumaServer/wiki"}
  end
  
  @doc """
  Ping command.
  """
  @spec ping :: Response.t
  def ping do
    responses = ["Kuma?", "Kuma~!", "Kuma...", "Kuma!!", "Kuma.", "Kuma...?"]
    reply %{text: Enum.random(responses)}
  end
end