defmodule KumaServer.Logger do
  require Logger

  def log(:recv, data) do
    to_console(:recv, data)
    to_file(:recv, data)
  end

  def log(:send, data, message) do
    to_console(:send, data, message)
    to_file(:send, data, message)
  end

  def to_console(:recv, data) do
    cond do
      data.channel.private ->
        Logger.info "[#{data.protocol}] #{if data.guild.name, do: "[" <> data.guild.name <> "] "}[private] #{data.user.name}: #{data.message.text}"
      true ->
        Logger.info "[#{data.protocol}] [#{data.guild.name}] [#{if data.channel.nsfw, do: '!'}\##{data.channel.name}] #{if data.user.moderator, do: '+'}#{data.user.name}: #{data.message.text}"
    end
  end

  def to_console(:send, data, message) do
    cond do
      data.channel.private ->
        Logger.info "[#{data.protocol}] #{if data.guild.name, do: "[" <> data.guild.name <> "] "}[private] kumakaini: #{message}"
      true ->
        Logger.info "[#{data.protocol}] [#{data.guild.name}] [#{if data.channel.nsfw, do: '!'}\##{data.channel.name}] +kumakaini: #{message}"
    end
  end

  def to_file(:recv, data) do
    logfolder = cond do
      data.channel.private ->
        "/home/bowan/bots/_log/#{data.protocol}#{if data.guild.name, do: "/" <> data.guild.name}/private"
      true ->
        "/home/bowan/bots/_log/#{data.protocol}/#{data.guild.name}"
    end

    unless File.exists?(logfolder), do: File.mkdir_p(logfolder)

    logfile = cond do
      data.channel.private -> "#{data.user.name}.log"
      true -> "#{data.channel.name}.log"
    end

    time = DateTime.utc_now |> DateTime.to_iso8601
    logline = "[#{time}] #{if data.user.moderator, do: '+'}#{data.user.name}: #{data.message.text}\n"

    File.write!("#{logfolder}/#{logfile}", logline, [:append])
  end

  def to_file(:send, data, message) do
    logfolder = cond do
      data.channel.private ->
        "/home/bowan/bots/_log/#{data.protocol}#{if data.guild.name, do: "/" <> data.guild.name}/private"
      true ->
        "/home/bowan/bots/_log/#{data.protocol}/#{data.guild.name}"
    end

    unless File.exists?(logfolder), do: File.mkdir(logfolder)

    logfile = cond do
      data.channel.private -> "#{data.user.name}.log"
      true -> "#{data.channel.name}.log"
    end

    kuma = cond do
      data.channel.private -> "kumakaini"
      true -> "+kumakaini"
    end

    time = DateTime.utc_now |> DateTime.to_iso8601
    logline = "[#{time}] #{kuma}: #{message}\n"

    File.write!("#{logfolder}/#{logfile}", logline, [:append])
  end
end