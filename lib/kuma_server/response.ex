defmodule KumaServer.Response do
  @typedoc "if there is a response or not"
  @type reply :: boolean

  @typedoc "reason of a false response"
  @type reason :: String.t

  @typedoc "text response"
  @type text :: String.t

  @typedoc "url of the image response"
  @type image_url :: String.t

  @typedoc "response content"
  @type response :: %{
    text: text,
    image: image_url
  }

  @enforce_keys [:reply]
  defstruct [:reply, :reason, :response]
  @type t :: %__MODULE__{
    reply: reply,
    reason: reason,
    response: response
  }
end