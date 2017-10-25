defmodule KumaServer.Commands.Stream do
  import KumaServer.Util
  alias KumaServer.Response
  
  @moduledoc """
  Commands related to the stream.
  """
  
  @doc """
  Returns rekyuu's local time.
  """
  @spec local_time :: Response.t
  def local_time do
    {{_, _, _}, {hour, minute, _}} = :calendar.local_time

    h = cond do
      hour <= 9 -> "0#{hour}"
      true      -> "#{hour}"
    end

    m = cond do
      minute <= 9 -> "0#{minute}"
      true        -> "#{minute}"
    end

    reply %{text: "It is #{h}:#{m} MST rekyuu's time."}
  end
  
  @doc """
  Returns lastfm now playing info if rekyuu is listening to music.
  """
  @spec now_playing :: Response.t | nil
  def now_playing do
    timeframe = :os.system_time(:seconds) - 180
    request = 
      "http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=rekyuu&api_key=#{Application.get_env(:kuma_server, :lastfm_key)}&format=json&limit=1&from=#{timeframe}"
      |> HTTPoison.get!

    response = Poison.Parser.parse!((request.body), keys: :atoms)
    track = response.recenttracks.track

    case List.first(track) do
      nil -> nil
      song -> reply %{text: "#{song.artist.'#text'} - #{song.name} [#{song.album.'#text'}]"}
    end
  end
  
  @doc """
  Returns stream uptime, if live.
  """
  @spec uptime :: Response.t
  def uptime do
    request = 
      "https://decapi.me/twitch/uptime?channel=rekyuus" 
      |> HTTPoison.get!

    case request.body do
      "rekyuus is offline" -> reply %{text: "Stream is not online!"}
      time -> reply %{text: "Stream has been live for #{time}."}
    end
  end
end