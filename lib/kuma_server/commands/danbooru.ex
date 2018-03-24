defmodule KumaServer.Commands.Danbooru do
  import KumaServer.Util
  require Logger
  alias KumaServer.{Request, Response}

  @moduledoc """
  Requests specific for Danbooru.
  """

  @doc """
  Query Danbooru using one or two, or no tags.

  Using no tags will search `order:rank`.
  """
  @spec basic(Request.t) :: Response.t
  def basic(data) do
    request_tags = case length(data.message.text |> String.split) do
      1 -> ["order:rank"]
      _ ->
        [_ | tags] = data.message.text |> String.split
        tags
    end

    reply response(request_tags)
  end

  @doc """
  Query Danbooru using one tag and `rating:safe`.

  Using no tags will search `order:rank`.
  """
  @spec safe(Request.t) :: Response.t
  def safe(data) do
    request_tags = case length(data.message.text |> String.split) do
      1 -> ["order:rank", "rating:s"]
      _ ->
        [_ | tags] = data.message.text |> String.split
        ["rating:s"] ++ tags
    end

    reply response(request_tags)
  end

  @doc """
  Query Danbooru using one tag and `rating:questionable`.

  Using no tags will search `order:rank`.
  """
  @spec questionable(Request.t) :: Response.t
  def questionable(data) do
    request_tags = case length(data.message.text |> String.split) do
      1 -> ["order:rank", "rating:q"]
      _ ->
        [_ | tags] = data.message.text |> String.split
        ["rating:q"] ++ tags
    end

    reply response(request_tags)
  end

  @doc """
  Query Danbooru using one tag and `rating:explicit`.

  Using no tags will search `order:rank`.
  """
  @spec explicit(Request.t) :: Response.t
  def explicit(data) do
    request_tags = case length(data.message.text |> String.split) do
      1 -> ["order:rank", "rating:e"]
      _ ->
        [_ | tags] = data.message.text |> String.split
        ["rating:e"] ++ tags
    end

    reply response(request_tags)
  end

  @doc """
  This function creates a response from two tags.

  Returns text and and image on success.
  """
  @spec response(list) :: map
  def response(tags) do
    case tags |> Enum.member?("help") do
      "help" -> "https://github.com/KumaKaiNi/KumaServer"
    _ ->
      case query(tags) do
        {post_id, image, result} ->
          character = result.tag_string_character |> String.split
          copyright = result.tag_string_copyright |> String.split

          artist =
            result.tag_string_artist
            |> String.split("_")
            |> Enum.join(" ")

          {char, copy} =
            case {length(character), length(copyright)} do
              {2, _} ->
                first_char =
                  List.first(character)
                  |> String.split("(")
                  |> List.first
                  |> titlecase("_")

                second_char =
                  List.last(character)
                  |> String.split("(")
                  |> List.first
                  |> titlecase("_")

                {"#{first_char} and #{second_char}",
                 List.first(copyright) |> titlecase("_")}
              {1, _} ->
                {List.first(character)
                 |> String.split("(")
                 |> List.first
                 |> titlecase("_"),
                 List.first(copyright) |> titlecase("_")}
              {_, 1} -> {"Multiple", List.first(copyright) |> titlecase("_")}
              {_, _} -> {"Multiple", "Various"}
            end

          extension = image |> String.split(".") |> List.last

          cond do
            Enum.member?(["jpg", "png", "gif"], extension) ->
              %{
                text: "",
                image: %{
                  url: image,
                  source: "https://danbooru.donmai.us/posts/#{post_id}",
                  description: "#{char} - #{copy}\nDrawn by #{artist}",
                  referrer: "danbooru.donmai.us"
                }
              }
            true ->
              thumbnail = "http://danbooru.donmai.us#{result.preview_file_url}"

              %{
                text: "",
                image: %{
                  url: thumbnail,
                  source: "https://danbooru.donmai.us/posts/#{post_id}",
                  description: "#{char} - #{copy}\nDrawn by #{artist}",
                  referrer: "danbooru.donmai.us (animated)"
                }
              }
          end
        message -> %{text: message}
      end
    end
  end

  @doc """
  This function queries danbooru using two tags.

  If any tag in the blacklist is found, it will instead send a result for a Mouku meme. Returns a random result or "Nothing Found!" if no results.
  """
  @spec query(list) :: map | String.t
  def query(raw_tags) do
    # TODO: Add to blacklist command
    # List of blacklisted words to return a meme instead
    #blacklist = query_data(:danbooru, :blacklist)
    blacklist = ["what", "scat", "guro", "gore", "loli", "shota", "prison", "furry"]
    # TODO: Add to replacements command
    # Map of word => replacement
    #replacements = query_data(:danbooru, :replacements)

    processed_tags = for tag <- raw_tags do
      cond do
        tag == "azur_lane" -> "kantai_collection"
        tag == "atz"       -> "kurumizawa_satanichia_mcdowell"
        Enum.member?(blacklist, tag) -> false
        true -> tag
      end
    end

    tags = cond do
      Enum.member?(processed_tags, false) -> ["shangguan_feiying", "meme"]
      true -> for tag <- processed_tags do
        tag |> URI.encode_www_form
      end
    end

    request_tags = tags |> Enum.take(6) |> Enum.join("+")
    request_url = "https://danbooru.donmai.us/posts.json?limit=50&page=1&random=true&tags=#{request_tags}"
    request_auth = [hackney: [basic_auth: {
      Application.get_env(:kuma_server, :danbooru_login),
      Application.get_env(:kuma_server, :danbooru_api_key)
    }]]

    request = request_url |> HTTPoison.get!(%{}, request_auth)

    try do
      results = Poison.Parser.parse!((request.body), keys: :atoms)
      result = results
      |> Enum.shuffle
      |> Enum.find(fn post ->
        is_image?(post.file_url) == true
        && is_dupe?(:dan, post.file_url) == false
        && post.is_deleted == false
      end)

      post_id = Integer.to_string(result.id)

      image = if URI.parse(result.file_url).host do
        result.file_url
      else
        "http://danbooru.donmai.us#{result.file_url}"
      end

      {post_id, image, result}
    rescue
      Enum.EmptyError -> "Nothing found!"
      UndefinedFunctionError -> "Nothing found!"
      error ->
        Logger.error "error in danbooru"
        IO.inspect error
    end
  end
end
