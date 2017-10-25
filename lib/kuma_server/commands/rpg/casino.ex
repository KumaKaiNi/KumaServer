defmodule KumaServer.Commands.RPG.Casino do
  import KumaServer.Util
  alias KumaServer.{Request, Response}
  
  @moduledoc """
  Commands for gambling coins.
  """
  
  @doc """
  Slot machine.
  
  All losses go to the jackpot.
  """
  @spec slots(Request.t) :: Response.t
  def slots(data) do
    username = case data.source.protocol do
      "discord" -> query_data(:links, data.user.id)
      "irc" -> data.user.name
    end

    case username do
      nil -> reply %{text: "You need to link your Twitch account. Be sure to DM me `!link <twitch username>` first."}
      username ->
        case data.message.text |> String.split |> length do
          1 -> reply %{text: "Usage: `!slots <1-25>`"}
          _ ->
            [_ | [bet | _]] = data.message.text |> String.split
            bet = bet |> Integer.parse

            case bet do
              {bet, _} ->
                cond do
                  bet > 25 -> 
                    reply %{text: "You must bet between 1 and 25 coins."}
                  bet < 1  -> 
                    reply %{text: "You must bet between 1 and 25 coins."}
                  true ->
                    bank = query_data(:bank, username)

                    cond do
                      bank < bet -> %{text: "You do not have enough coins."}
                      true ->
                        reel = ["⚓", "⭐", "🍋", "🍊", "🍒", "🌸"]

                        {col1, col2, col3} = {Enum.random(reel), Enum.random(reel), Enum.random(reel)}

                        bonus = case {col1, col2, col3} do
                          {"🌸", "🌸", "⭐"} -> 2
                          {"🌸", "⭐", "🌸"} -> 2
                          {"⭐", "🌸", "🌸"} -> 2
                          {"🌸", "🌸", _}    -> 1
                          {"🌸", _, "🌸"}    -> 1
                          {_, "🌸", "🌸"}    -> 1
                          {"🍒", "🍒", "🍒"} -> 4
                          {"🍊", "🍊", "🍊"} -> 6
                          {"🍋", "🍋", "🍋"} -> 8
                          {"⚓", "⚓", "⚓"} -> 10
                          _ -> 0
                        end

                        result = case bonus do
                          0 ->
                            {stats, _} = get_user_stats(username)
                            odds =
                              1250 * :math.pow(1.02256518256, -1 * stats.luck)
                              |> round

                            if one_to(odds) do
                              "You didn't win, but the machine gave you your money back."
                            else
                              store_data(:bank, username, bank - bet)

                              kuma = query_data(:bank, "kumakaini")
                              store_data(:bank, "kumakaini", kuma + bet)

                              "Sorry, you didn't win anything."
                            end
                          bonus ->
                            payout = bet * bonus
                            store_data(:bank, username, bank - bet + payout)
                            "Congrats, you won #{payout} coins!"
                        end

                        reply %{text: "#{col1} #{col2} #{col3} (#{result})"}
                    end
                end
              :error -> reply %{text: "Usage: !slots <bet>, where <bet> is a number between 1 and 25."}
            end
        end
    end
  end

  @doc """
  Gets the current jackpot.
  """
  @spec jackpot :: Response.t
  def jackpot do
    jackpot = query_data(:bank, "kumakaini")
    reply %{text: "There are #{jackpot} coins in the jackpot."}
  end
end
