defmodule KumaServer.Commands.Image do
  import KumaServer.Util
  alias KumaServer.Response

  @moduledoc """
  Specifies other image-related commands.
  """

  @doc """
  Returns a random smug anime girl.
  """
  @spec smug :: Response.t
  def smug do
    auth = %{"Authorization" => "Client-ID #{Application.get_env(:kuma_server, :imgur_client_id)}"}

    request = HTTPoison.get!("https://api.imgur.com/3/album/zSNC1", auth)
    response = Poison.Parser.parse!((request.body), keys: :atoms)
    result = response.data.images |> Enum.random

    reply %{
      text: "", 
      image: %{
        url: result.link, 
        source: "https://imgur.com/#{result.id}", 
        description: "", 
        referrer: "imgur.com"
      }
    }
  end
end