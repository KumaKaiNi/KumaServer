defmodule KumaServer.Util do
  @moduledoc """
  Utility functions used throughout the server
  """

  @doc """
  Transforms all keys in a given map from strings to atoms.
  """
  @spec keys_to_atoms(map) :: map
  def keys_to_atoms(struct) do
    Enum.reduce struct, %{}, fn({key, val}, acc) ->
      case {is_atom(key), is_map(val)} do
        {true, false}  -> Map.put(acc, key, val)
        {false, false} -> Map.put(acc, String.to_atom(key), val)
        {true, true}   -> Map.put(acc, key, keys_to_atoms(val))
        {false, true}  -> Map.put(acc, String.to_atom(key), keys_to_atoms(val))
      end
    end
  end

  @doc """
  Creates a response struct where the reply is true and the map provided is the response.
  """
  @spec reply(map, String.t) :: KumaServer.Response.t
  def reply(map, reason \\ "ok") do
    struct KumaServer.Response, %{reply: true, response: map, reason: reason}
  end

  @doc """
  Creates a response struct where the reply is false with an optional reason.
  """
  @spec noreply(String.t) :: KumaServer.Response.t
  def noreply(reason \\ "no response") do
    struct KumaServer.Response, %{reply: false, reason: reason}
  end

  @doc """
  Helper to see if a file was last posted.
  """
  @spec is_dupe?(atom | String.t, String.t) :: boolean | nil
  def is_dupe?(source, filename) do
    file = query_data("dupes", source)

    cond do
      file == nil ->
        store_data("dupes", source, filename)
        false
      file != filename ->
        store_data("dupes", source, filename)
        false
      file == filename -> true
      true -> nil
    end
  end

  @doc """
  Checks to see if a url is a link to image.
  """
  @spec is_image?(String.t) :: boolean
  def is_image?(url) do
    image_types = [".jpg", ".jpeg", ".gif", ".png", ".mp4"]
    Enum.member?(image_types, Path.extname(url))
  end

  @doc """
  Helper to convert a string to title case.

  Optionally accepts `mod` for splitting the string, otherwise will split for spaces.
  """
  @spec titlecase(String.t, String.t) :: String.t
  def titlecase(title, mod \\ " ") do
    words = title |> String.split(mod)

    for word <- words do
      word |> String.capitalize
    end |> Enum.join(" ")
  end

  @doc """
  Stores data in a dets table.
  """
  @spec store_data(atom | String.t, String.t, any) :: :ok | {:error, any}
  def store_data(table, key, value) do
    file = '/home/bowan/bots/_db/#{table}.dets'
    {:ok, _} = :dets.open_file(table, [file: file, type: :set])
    response = :dets.insert(table, {key, value})

    :dets.close(table)
    response
  end

  @doc """
  Queries data from a dets table with the provided key.
  """
  @spec query_data(atom | String.t, String.t) :: any
  def query_data(table, key) do
    file = '/home/bowan/bots/_db/#{table}.dets'
    {:ok, _} = :dets.open_file(table, [file: file, type: :set])
    result = :dets.lookup(table, key)

    response =
      case result do
        [{_, value}] -> value
        [] -> nil
      end

    :dets.close(table)
    response
  end

  @doc """
  Queries all data in a dets table.
  """
  @spec query_all_data(atom | String.t) :: [any]
  def query_all_data(table) do
    file = '/home/bowan/bots/_db/#{table}.dets'
    {:ok, _} = :dets.open_file(table, [file: file, type: :set])
    result = :dets.match_object(table, {:"$1", :"$2"})

    response =
      case result do
        [] -> nil
        values -> values
      end

    :dets.close(table)
    response
  end

  @doc """
  Deletes data in a dets table with a provided key.
  """
  @spec delete_data(atom | String.t, String.t) :: :ok | {:error, any}
  def delete_data(table, key) do
    file = '/home/bowan/bots/_db/#{table}.dets'
    {:ok, _} = :dets.open_file(table, [file: file, type: :set])

    response = :dets.delete(table, key)

    :dets.close(table)    
    response
  end
end