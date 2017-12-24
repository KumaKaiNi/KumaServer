defmodule KumaServer.Commands.Danbooru do
  import KumaServer.Util
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
    {tag1, tag2} = case length(data.message.text |> String.split) do
      1 -> {"order:rank", ""}
      2 ->
        [_ | [tag1 | _]] = data.message.text |> String.split
        {tag1, ""}
      _ ->
        [_ | [tag1 | [tag2 | _]]] = data.message.text |> String.split
        {tag1, tag2}
    end

    reply response(tag1, tag2)
  end

  @doc """
  Query Danbooru using one tag and `rating:safe`.

  Using no tags will search `order:rank`.
  """
  @spec safe(Request.t) :: Response.t
  def safe(data) do
    {tag1, tag2} = case length(data.message.text |> String.split) do
      1 -> {"order:rank", "rating:s"}
      _ ->
        [_ | [tag1 | _]] = data.message.text |> String.split
        {tag1, "rating:s"}
    end

    reply response(tag1, tag2)
  end

  @doc """
  Query Danbooru using one tag and `rating:questionable`.

  Using no tags will search `order:rank`.
  """
  @spec questionable(Request.t) :: Response.t
  def questionable(data) do
    {tag1, tag2} = case length(data.message.text |> String.split) do
      1 -> {"order:rank", "rating:q"}
      _ ->
        [_ | [tag1 | _]] = data.message.text |> String.split
        {tag1, "rating:q"}
    end

    reply response(tag1, tag2)
  end

  @doc """
  Query Danbooru using one tag and `rating:explicit`.

  Using no tags will search `order:rank`.
  """
  @spec explicit(Request.t) :: Response.t
  def explicit(data) do
    {tag1, tag2} = case length(data.message.text |> String.split) do
      1 -> {"order:rank", "rating:e"}
      _ ->
        [_ | [tag1 | _]] = data.message.text |> String.split
        {tag1, "rating:e"}
    end

    reply response(tag1, tag2)
  end

  @doc """
  This function creates a response from two tags. 

  Returns text and and image on success.
  """
  @spec response(String.t, String.t) :: map
  def response(tag1, tag2) do
    case tag1 do
      "help" -> "https://github.com/KumaKaiNi/KumaServer"
    _ ->
      case query(tag1, tag2) do
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
  @spec query(String.t, String.t) :: {integer, String.t, map} | String.t
  def query(tag1, tag2) do
    require Logger

    dan = "danbooru.donmai.us"
    blacklist = ["what", "scat", "guro", "gore", "loli", "shota"]

    tag1 = tag1 
    |> String.replace("azur_lane", "kantai_collection")
    |> String.replace("atz", "kurumizawa_satanichia_mcdowell")
    
    tag2 = tag2 
    |> String.replace("azur_lane", "kantai_collection")
    |> String.replace("atz", "kurumizawa_satanichia_mcdowell")

    safe1 = Enum.member?(blacklist, tag1)
    safe2 = Enum.member?(blacklist, tag2)

    {tag1, tag2} = case {safe1, safe2} do
      {_, true}      -> {"shangguan_feiying", "meme"}
      {true, _}      -> {"shangguan_feiying", "meme"}
      {false, false} -> {tag1, tag2}
    end

    tag1 = tag1 |> String.split |> Enum.join("_") |> URI.encode_www_form
    tag2 = tag2 |> String.split |> Enum.join("_") |> URI.encode_www_form

    request = 
      "http://#{dan}/posts.json?limit=50&page=1&tags=#{tag1}+#{tag2}" 
      |> HTTPoison.get!

    try do
      results = Poison.Parser.parse!((request.body), keys: :atoms)
      result = 
        results 
        |> Enum.shuffle 
        |> Enum.find(fn post -> 
          is_image?(post.file_url) == true 
          && is_dupe?("dan", post.file_url) == false 
          && post.is_deleted == false 
        end)

      post_id = Integer.to_string(result.id)
      image = "http://#{dan}#{result.file_url}"

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