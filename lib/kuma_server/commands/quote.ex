defmodule KumaServer.Commands.Quote do
  import KumaServer.Util
  alias KumaServer.{Request, Response}

  @doc """
  Pulls a random quote, or quote by ID if specified.
  """
  @spec get(Request.t) :: Response.t
  def get(data) do
    {quote_id, quote_text} = case length(data.message.text |> String.split) do
      1 ->
        quotes = query_all_data(:quotes)
        Enum.random(quotes)
      _ ->
        [_ | [quote_id | _]] = data.message.text |> String.split

        case quote_id |> Integer.parse do
          {quote_id, _} ->
            case query_data(:quotes, quote_id) do
              nil -> {"65535", "Quote does not exist. - KumaKaiNi, 2017"}
              quote_text -> {quote_id, quote_text}
            end
          :error ->
            quotes = query_all_data(:quotes)
            Enum.random(quotes)
        end
    end

    reply %{text: "[#{quote_id}] #{quote_text}"}
  end

  @doc """
  Adds a quote.
  """
  @spec add(Request.t) :: Response.t
  def add(data) do
    [_ | [_ | quote_text]] = data.message.text |> String.split
    quote_text = quote_text |> Enum.join(" ")

    quotes = case query_all_data(:quotes) do
      nil -> nil
      quotes -> quotes |> Enum.sort
    end

    quote_id = case quotes do
      nil -> 1
      _ ->
        {quote_id, _} = List.last(quotes)
        quote_id + 1
    end

    store_data(:quotes, quote_id, quote_text)
    reply %{text: "Quote added! #{quote_id} quotes total."}
  end

  @doc """
  Deletes a quote by ID.
  """
  @spec delete(Request.t) :: Response.t
  def delete(data) do
    [_ | [_ | quote_id]] = data.message.text |> String.split

    case List.first(quote_id) |> Integer.parse do
      {quote_id, _} ->
        case query_data(:quotes, quote_id) do
          nil -> reply %{text: "Quote #{quote_id} does not exist."}
          _ ->
            delete_data(:quotes, quote_id)
            reply %{text: "Quote removed."}
        end
      :error -> reply %{text: "You didn't specify an ID number."}
    end
  end
end