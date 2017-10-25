defmodule KumaServer.Logger do
  require Logger

  def log(:recv, content) do
    to_console(:recv, content)
    to_file(:recv, content)
  end

  def log(:send, content, message) do
    to_console(:send, content, message)
    to_file(:send, content, message)
  end

  def to_console(:recv, content) do
    cond do
      content.source.channel.private ->
        Logger.info "[#{content.source.protocol}] #{if content.source.guild.name, do: "[" <> content.source.guild.name <> "] "}[private] #{content.user.name}: #{content.message.text}"
      true ->
        Logger.info "[#{content.source.protocol}] [#{content.source.guild.name}] [#{if content.source.channel.nsfw, do: '!'}\##{content.source.channel.name}] #{if content.user.moderator, do: '+'}#{content.user.name}: #{content.message.text}"
    end
  end

  def to_console(:send, content, message) do
    cond do
      content.source.channel.private ->
        Logger.info "[#{content.source.protocol}] #{if content.source.guild.name, do: "[" <> content.source.guild.name <> "] "}[private] kumakaini: #{message}"
      true ->
        Logger.info "[#{content.source.protocol}] [#{content.source.guild.name}] [#{if content.source.channel.nsfw, do: '!'}\##{content.source.channel.name}] +kumakaini: #{message}"
    end
  end

  def to_file(:recv, content) do
    logfolder = cond do
      content.source.channel.private ->
        "/home/bowan/bots/_log/#{content.source.protocol}#{if content.source.guild.name, do: "/" <> content.source.guild.name}/private"
      true ->
        "/home/bowan/bots/_log/#{content.source.protocol}/#{content.source.guild.name}"
    end

    unless File.exists?(logfolder), do: File.mkdir_p(logfolder)

    logfile = cond do
      content.source.channel.private -> "#{content.user.name}.log"
      true -> "#{content.source.channel.name}.log"
    end

    time = DateTime.utc_now |> DateTime.to_iso8601
    logline = "[#{time}] #{if content.user.moderator, do: '+'}#{content.user.name}: #{content.message.text}\n"

    File.write!("#{logfolder}/#{logfile}", logline, [:append])
  end

  def to_file(:send, content, message) do
    logfolder = cond do
      content.source.channel.private ->
        "/home/bowan/bots/_log/#{content.source.protocol}#{if content.source.guild.name, do: "/" <> content.source.guild.name}/private"
      true ->
        "/home/bowan/bots/_log/#{content.source.protocol}/#{content.source.guild.name}"
    end

    unless File.exists?(logfolder), do: File.mkdir(logfolder)

    logfile = cond do
      content.source.channel.private -> "#{content.user.name}.log"
      true -> "#{content.source.channel.name}.log"
    end

    kuma = cond do
      content.source.channel.private -> "kumakaini"
      true -> "+kumakaini"
    end

    time = DateTime.utc_now |> DateTime.to_iso8601
    logline = "[#{time}] #{kuma}: #{message}\n"

    File.write!("#{logfolder}/#{logfile}", logline, [:append])
  end
end