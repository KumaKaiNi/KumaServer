defmodule KumaServer.Commands.RPG.Stats do
  import KumaServer.Util
  alias KumaServer.{Request, Response}

  @moduledoc """
  Commands dealing with the user's stats.
  """

  @doc """
  Retrieves the user's stats
  """
  @spec user_stats(Request.t) :: Response.t
  def user_stats(data) do
    username = case data.protocol do
      "discord" -> query_data(:links, data.user.id)
      "irc" -> data.user.name
    end

    case username do
      nil -> reply %{text: "You need to link your Twitch account. Be sure to DM me `!link <twitch username>` first."}
      username ->
        bank = query_data(:bank, username)
        bank = case bank do
          nil -> 0
          bank -> bank
        end

        {stats, next_lvl_cost} = get_user_stats(username)

        case data.protocol do
          "discord" -> reply %{text: "**#{username}'s Stats**\nLevel #{stats.level}, #{bank} coins\n```Level Up Cost: #{next_lvl_cost} coins\n\n[VIT] #{stats.vit} [END] #{stats.end}\n[STR] #{stats.str} [DEX] #{stats.dex}\n[INT] #{stats.int} [LUK] #{stats.luck}\n```"}
          "irc" ->
            reply %{text: "[#{username}'s Stats] [Level #{stats.level}] [Coins: #{bank}] [Level Up Cost: #{next_lvl_cost}] [Vitality: #{stats.vit}] [Endurance: #{stats.end}] [Strength: #{stats.str}] [Dexterity: #{stats.dex}] [Intelligence: #{stats.int}] [Luck: #{stats.luck}]"}
        end
    end
  end

  @doc """
  Command to level up a user.

  If no stat is provided, the current level will be given. If the user doesn't have enough coins to level, it will tell them how many they need.
  """
  @spec level_up(Request.t) :: Response.t
  def level_up(data) do
    username = case data.protocol do
      "discord" -> query_data(:links, data.user.id)
      "irc" -> data.user.name
    end

    case username do
      nil -> reply %{text: "You need to link your Twitch account. Be sure to DM me `!link <twitch username>` first."}
      username ->
        case data.message.text |> String.split |> length do
          1 ->
            bank = query_data(:bank, username)
            {stats, level_up_cost} = get_user_stats(username)

            reply %{text: "You are Level #{stats.level}. It will cost #{level_up_cost} coins to level up. You currently have #{bank} coins. Type `!level <stat>` to do so."}
          _ ->
            [_ | [stat | _]] = data.message.text |> String.split
            {stats, level_up_cost} = get_user_stats(username)
            bank = query_data(:bank, username)

            cond do
              level_up_cost > bank -> reply %{text: "You do not have enough coins. #{level_up_cost} coins are required. You currently have #{bank} coins."}
              true ->
                stat = case stat do
                  "vit" -> "vitality"
                  "end" -> "endurance"
                  "str" -> "strength"
                  "dex" -> "dexterity"
                  "int" -> "intelligence"
                  stat -> stat
                end

                stats = case stat do
                  "vitality"      -> %{stats | vit: stats.vit + 1}
                  "endurance"     -> %{stats | end: stats.end + 1}
                  "strength"      -> %{stats | str: stats.str + 1}
                  "dexterity"     -> %{stats | dex: stats.dex + 1}
                  "intelligence"  -> %{stats | int: stats.int + 1}
                  "luck"          -> %{stats | luck: stats.luck + 1}
                  _ -> :error
                end

                case stats do
                  :error -> %{text: "That is not a valid stat. Valid stats are `vit`, `end`, `str`, `dex`, `int`, `luck`."}
                  stats ->
                    stats = %{stats | level: stats.level + 1}

                    store_data(:bank, username, bank - level_up_cost)
                    store_data(:stats, username, stats)
                    reply %{text: "You are now Level #{stats.level}! You have #{bank - level_up_cost} coins left."}
                end
            end
        end
    end
  end

  @doc """
  Sends a user back to level 2 and returns some coins to respec.

  Requires confirmation from the user before proceeding.
  """
  @spec respec(Request.t) :: Response.t
  def respec(data) do
    username = case data.protocol do
      "discord" -> query_data(:links, data.user.id)
      "irc" -> data.user.name
    end

    case username do
      nil -> reply %{text: "You need to link your Twitch account. Be sure to DM me `!link <twitch username>` first."}
      username -> 
        {stats, _level_up_cost} = get_user_stats(username)

        cond do
          stats.level < 3 -> reply %{text: "You must be level 3 or higher to respec."}
          true ->
            case data.message.text |> String.split |> List.last do
              "confirm"->
                bank = query_data(:bank, username)

                return = for x <- 2..(stats.level - 1) do
                  calculate_level_up_cost(x)
                end |> Enum.sum

                stats = %{
                  level: 1,
                  vit: 10,
                  end: 10,
                  str: 10,
                  dex: 10,
                  int: 10,
                  luck: 10
                }

                store_data(:bank, username, bank + return)
                store_data(:stats, username, stats)

                reply %{text: "You have been returned to level 1 and you received #{return} coins."}
              _ -> reply %{text: "Using this will put you back to level 1 and give you back some of your coins you used to level up. If you're sure you want to do this, type `!respec confirm`."}
            end
        end
    end
  end

  @doc """
  Helper for retrieving the user's stats and calculates the next level cost.
  """  
  @spec get_user_stats(String.t) :: {%{
    level: integer,
    vit: integer,
    end: integer,
    str: integer,
    dex: integer,
    int: integer,
    luck: integer
  }, integer}
  def get_user_stats(username) do
    stats = query_data(:stats, username)
    stats = case stats do
      nil -> %{
        level: 1,
        vit: 10,
        end: 10,
        str: 10,
        dex: 10,
        int: 10,
        luck: 10
      }
      stats -> stats
    end

    next_level = stats.level + 1
    {stats, calculate_level_up_cost(next_level)}
  end

  def calculate_level_up_cost(next_level) do
    round(:math.pow((3.741657388 * next_level), 2) + (100 * next_level))
  end
end