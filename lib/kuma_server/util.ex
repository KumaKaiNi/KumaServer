defmodule KumaServer.Util do
  def keys_to_atoms(struct) do
    Enum.reduce struct, %{}, fn({key, val}, acc) ->
      cond do
        is_map(val) -> Map.put(acc, String.to_atom(key), keys_to_atoms(val))
        true        -> Map.put(acc, String.to_atom(key), val)
      end
    end
  end
end