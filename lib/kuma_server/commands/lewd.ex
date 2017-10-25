defmodule KumaServer.Commands.Lewd do
  import KumaServer.Util
  alias KumaServer.{Request, Response}

  @moduledoc """
  Lewd commands.
  """

  @doc """
  Pulls a random doujin from nhentai using one or more tags.
  """
  @spec nhentai(Request.t) :: Response.t
  def nhentai(data) do
    [_ | tags] = data.content |> String.split

    case tags do
      [] -> reply %{text: "You must search with at least one tag."}
      tags ->
        tags = for tag <- tags do
          tag |> URI.encode_www_form
        end |> Enum.join("+")

        request = "https://nhentai.net/api/galleries/search?query=#{tags}&sort=popular" |> HTTPoison.get!
        response = Poison.Parser.parse!((request.body), keys: :atoms)

        try do
          result = response.result |> Enum.shuffle |> Enum.find(fn doujin -> is_dupe?("nhentai", doujin.id) == false end)

          filetype = case List.first(result.images.pages).t do
            "j" -> "jpg"
            "g" -> "gif"
            "p" -> "png"
          end

          artists_tag = result.tags |> Enum.filter(fn(t) -> t.type == "artist" end)
          artists = for tag <- artists_tag, do: tag.name

          artist = case artists do
            [] -> ""
            artists -> "by #{artists |> Enum.sort |> Enum.join(", ")}\n"
          end

          cover = "https://i.nhentai.net/galleries/#{result.media_id}/1.#{filetype}"

          reply %{
            text: "", 
            image: %{
              url: cover, 
              source: "https://nhentai.net/g/#{result.id}", 
              description: "#{artist}", 
              referrer: result.title.pretty
            }
          }
      rescue
        KeyError -> reply %{text: "Nothing found!"}
      end
    end
  end
end