defmodule KumaServer.Util do
  def is_match(text, data) do
    Regex.compile!("^(#{text})") 
    |> Regex.match?(data.message.text)
  end

  def keys_to_atoms(struct) do
    Enum.reduce struct, %{}, fn({key, val}, acc) ->
      cond do
        is_map(val) -> Map.put(acc, String.to_atom(key), keys_to_atoms(val))
        true        -> Map.put(acc, String.to_atom(key), val)
      end
    end
  end

  def reply(json_map, reason \\ "ok") do
    response = %{reply: true, response: json_map, reason: reason}
    struct KumaServer.Response, response
  end

  def noreply(reason) do
    struct KumaServer.Response, %{reply: false, reason: reason}
  end
end