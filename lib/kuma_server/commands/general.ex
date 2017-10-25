defmodule KumaServer.Commands.General do
  import KumaServer.Util
  alias KumaServer.Response
  
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

  @doc """
  Response for thanking kuma.
  """
  @spec thanks :: Response.t
  def thanks do
    replies = ["np", "don't mention it", "anytime", "sure thing", "ye whateva"]
    reply %{text: Enum.random(replies)}
  end

  @doc """
  Response for saying hello.
  """
  @spec hello :: Response.t
  def hello do
    replies = ["sup", "yo", "ay", "hi", "wassup"]
    reply %{text: Enum.random(replies)}
  end

  @doc """
  Might respond to "same".
  """
  @spec same :: Response.t
  def same do
    if one_to(25), do: reply %{text: "same"}
  end
end