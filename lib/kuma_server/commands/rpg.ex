defmodule KumaServer.Commands.RPG do
  import KumaServer.Util
  alias KumaServer.{Request, Response}

  @moduledoc """
  Specifies general commands for the RPG module.
  """

  @doc """
  Pulls the top five in levels, then by coins.

  Incoming message is used for formatting.
  """
  @spec leaderboard(Request.t) :: Response.t
  def leaderboard(data) do
    users = query_all_data(:stats)

    top5 = for {username, stats} <- users do
      unless Enum.member?(["rekyuus", "kumakaini", "nightbot"], username) do
        coins = query_data(:bank, username)
        {stats.level, coins, username}
      end
    end |> Enum.sort |> Enum.reverse |> Enum.take(5) |> Enum.uniq
    top5 = top5 -- [nil]

    top5_length = cond do
      length(top5) < 5 -> length(top5) - 1
      true -> 4
    end

    top5_strings = for x <- 0..top5_length do
      {:ok, {level, coins, username}} = Enum.fetch(top5, x)
      "[#{x + 1}] #{username} (Level #{level}, #{coins} Coins)"
    end

    case data.source.protocol do
      "discord" -> 
        reply %{text: "```\n#{top5_strings |> Enum.join("\n")}\n```"}
      "irc" -> reply %{text: top5_strings |> Enum.join(" ")}
    end
  end
end