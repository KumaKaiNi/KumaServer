defmodule KumaServer.Response do
  @typedoc "if there is a response or not"
  @type reply :: boolean

  @typedoc "reason of a false response"
  @type reason :: String.t

  @typedoc "text response"
  @type text :: String.t

  @typedoc "direct url of the image"
  @type image_url :: String.t

  @typedoc "url source for the image"
  @type image_source :: String.t

  @typedoc "description for the image"
  @type image_description :: String.t

  @typedoc "where the image came from (site name, etc)"
  @type image_referrer :: String.t

  @typedoc "image struct"
  @type image :: %{
    url: image_url,
    source: image_source,
    description: image_description,
    referrer: image_referrer
  }

  @typedoc "response content"
  @type response :: %{
    text: text,
    image: image
  }

  @enforce_keys [:reply]
  defstruct [reply: false, reason: nil, response: nil]
  @type t :: %__MODULE__{
    reply: reply,
    reason: reason,
    response: response
  }
end