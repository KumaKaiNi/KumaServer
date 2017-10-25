defmodule KumaServer.Commands.RPG.Bank do
  import KumaServer.Util
  alias KumaServer.{Request, Response}

  @moduledoc """
  Commands for dealing with user's coins.
  """

  @doc """
  Returns the user's current coin count.
  """
  @spec coins(Request.t) :: Response.t
  def coins(data) do
    username = case data.protocol do
      "discord" -> query_data(:links, data.user.id)
      "irc"     -> data.user.name
    end

    case username do
      nil -> reply %{text: "You need to link your Twitch account. Be sure to DM me `!link <twitch username>` first."}
      username ->
        bank = query_data(:bank, username)

        amount = case bank do
          nil -> "no"
          bank -> bank
        end

        reply %{text: "You have #{amount} coins."}
    end
  end
end