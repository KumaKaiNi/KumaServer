defmodule KumaServer.Commands.CustomCommand do
  import KumaServer.Util
  alias KumaServer.{Request, Response}

  @doc """
  Retrieves a custom command.
  """
  @spec query(Request.t) :: Response.t | nil
  def query(data) do
    case query_data(:commands, data.message.text) do
      nil -> nil
      response -> reply %{text: response}
    end
  end

  @doc """
  Creates a custom command.
  """
  @spec set(Request.t) :: Response.t | nil
  def set(data) do
    capture = ~r/^(!command\s[a-z]+)\s(?<command>[A-Za-z0-9]+)\s(?<action>.+)/

    case Regex.named_captures(capture, data.message.text) do
      %{"command" => command, "action" => action} ->
        command = command |> String.downcase
        exists = query_data(:commands, "!#{command}")
        store_data(:commands, "!#{command}", action)

        case exists do
          nil -> reply %{text: "Alright! Type !#{command} to use."}
          _   -> reply %{text: "Done, command !#{command} updated."}
        end
      _ -> nil
    end
  end

  @doc """
  Deletes a custom command.
  """
  @spec delete(Request.t) :: Response.t | nil
  def delete(data) do
    capture = ~r/^(!command\s[a-z]+)\s(?<command>[A-Za-z0-9]+)/

    case Regex.named_captures(capture, data.message.text) do
      %{"command" => command} ->
        command = command |> String.downcase
        exists = query_data(:commands, "!#{command}")

        case exists do
          nil -> reply %{text: "Command does not exist."}
          _   ->
            delete_data(:commands, "!#{command}")
            reply %{text: "Command !#{command} removed."}
        end
      _ -> nil
    end
  end

  @doc """
  Lists all custom commands.
  """
  @spec list_all_commands(Request.t) :: Response.t | nil
  def list_all_commands(data) do
    commands_db = query_all_data :commands

    commands_list = for entry <- commands_db do
      {command, _} = entry
      command
    end

    reply %{text: commands_list |> Enum.join(", ")}
  end
end