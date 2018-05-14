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
  @spec same :: Response.t | nil
  def same do
    if one_to(25), do: reply %{text: "same"}
  end
  
  @doc """
  Returns the current moon phase.
  """
  @spec moon_phase :: Response.t | nil
  def moon_phase do
    date = Date.utc_today
    
    {y, m, d} = cond do
      date.month <= 2 -> {date.year - 1, date.month + 12, date.day}
      true -> {date.year, date.month, date.day}
    end
    
    a = Kernel.trunc(y / 100)
    b = Kernel.trunc(a / 4)
    c = 2 - a + b
    e = Kernel.trunc(365.25 * (y + 4716))
    f = Kernel.trunc(30.6001 * (m + 1))
    
    cycle_length = 29.53
    julian_date = c + d + e + f - 1524.5
    days_since_new_moon = Kernel.trunc(julian_date - 2451549.5)
    new_moons = days_since_new_moon / cycle_length
    Kernel.trunc((new_moons - Kernel.trunc(new_moons)) * cycle_length)
    
    phase = cond do
      d == 29 -> "New Moon"
      d >= 23 -> "Waning Crescent"
      d == 22 -> "Last Quarter"
      d >= 16 -> "Waning Gibbous"
      d == 15 -> "Full Moon"
      d >=  9 -> "Waxing Gibbous"
      d ==  8 -> "First Quarter"
      d >=  2 -> "Waxing Crescent"
      d ==  1 -> "New Moon"
      d ==  0 -> "N̸̛̹̩͈͖̭̤͚̠̘̝̮͓͈̻̾̈̋̇͊̀̔̚͠͝e̷̡̧̼̩̰̼̞̖͙̮̙̰̳͑̇̑̽͆͆̇̍͘͠w̷̞̦̪̑̎̆̒ ̸̛̩͇̹̯̠̊͆̊Ḿ̵̲͕͔̼̘͙͍͇ͅơ̷̧̙͈͍̻̯̬͔̈́̐̂͌̏̚͘͜o̴̢͕̫̱̪̬̤̱̳͈̩̤̐̈͋̎̅́̿̏̊̕n̶̰̼̯̼͇͕̥̭̞̖͖̾̎́̄͆͂͋̽͌ͅ"
    end
  end
  
  %{text: phase}
end