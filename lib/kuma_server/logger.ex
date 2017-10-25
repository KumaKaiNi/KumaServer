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
      content.channel.private ->
        Logger.info "[#{content.protocol}] #{if content.guild.name, do: "[" <> content.guild.name <> "] "}[private] #{content.user.name}: #{content.message.text}"
      true ->
        Logger.info "[#{content.protocol}] [#{content.guild.name}] [#{if content.channel.nsfw, do: '!'}\##{content.channel.name}] #{if content.user.moderator, do: '+'}#{content.user.name}: #{content.message.text}"
    end
  end

  def to_console(:send, content, message) do
    cond do
      content.channel.private ->
        Logger.info "[#{content.protocol}] #{if content.guild.name, do: "[" <> content.guild.name <> "] "}[private] kumakaini: #{message}"
      true ->
        Logger.info "[#{content.protocol}] [#{content.guild.name}] [#{if content.channel.nsfw, do: '!'}\##{content.channel.name}] +kumakaini: #{message}"
    end
  end

  def to_file(:recv, content) do
    logfolder = cond do
      content.channel.private ->
        "/home/bowan/bots/_log/#{content.protocol}#{if content.guild.name, do: "/" <> content.guild.name}/private"
      true ->
        "/home/bowan/bots/_log/#{content.protocol}/#{content.guild.name}"
    end

    unless File.exists?(logfolder), do: File.mkdir_p(logfolder)

    logfile = cond do
      content.channel.private -> "#{content.user.name}.log"
      true -> "#{content.channel.name}.log"
    end

    time = DateTime.utc_now |> DateTime.to_iso8601
    logline = "[#{time}] #{if content.user.moderator, do: '+'}#{content.user.name}: #{content.message.text}\n"

    File.write!("#{logfolder}/#{logfile}", logline, [:append])
  end

  def to_file(:send, content, message) do
    logfolder = cond do
      content.channel.private ->
        "/home/bowan/bots/_log/#{content.protocol}#{if content.guild.name, do: "/" <> content.guild.name}/private"
      true ->
        "/home/bowan/bots/_log/#{content.protocol}/#{content.guild.name}"
    end

    unless File.exists?(logfolder), do: File.mkdir(logfolder)

    logfile = cond do
      content.channel.private -> "#{content.user.name}.log"
      true -> "#{content.channel.name}.log"
    end

    kuma = cond do
      content.channel.private -> "kumakaini"
      true -> "+kumakaini"
    end

    time = DateTime.utc_now |> DateTime.to_iso8601
    logline = "[#{time}] #{kuma}: #{message}\n"

    File.write!("#{logfolder}/#{logfile}", logline, [:append])
  end
end