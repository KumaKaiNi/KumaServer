defmodule KumaServer.Commands.CustomCommands do
  import KumaServer.Util
  alias KumaServer.{Request, Response}

  @doc """
  Retrieves a custom command.
  """
  @spec custom_command(Request.t) :: Response.t | nil
  def custom_command(data) do
    case query_data(:commands, data.message.text) do
      nil -> nil
      response - > reply %{text: response}
    end
  end

  @doc """
  Creates a custom command.
  """
  @spec custom_command_set(Request.t) :: Response.t | nil
  def custom_command_set(data) do
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
  @spec custom_command_delete(Request.t) :: Response.t | nil
  def custom_command_delete(data) do
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
end