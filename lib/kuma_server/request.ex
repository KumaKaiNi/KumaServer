defmodule KumaServer.Request do
  @typedoc "protocol of the message (discord, irc, etc)"
  @type protocol :: String.t

  @typedoc "guild id. used for discord snowflakes"
  @type guild_id :: String.t

  @typedoc "guild or server"
  @type guild_name :: String.t

  @typedoc "guild struct"
  @type guild :: %{
    id: guild_id,
    name: guild_name
  }

  @typedoc "channel id. used for discord snowflakes"
  @type channel_id :: String.t

  @typedoc "channel name"
  @type channel_name :: String.t

  @typedoc "whether or not the channel is private"
  @type channel_private :: boolean

  @typedoc "whether or not the channel is nsfw (should be true if private)"
  @type channel_nsfw :: boolean

  @typedoc "channel struct"
  @type channel :: %{
    id: channel_id,
    name: channel_name,
    private: channel_private,
    nsfw: channel_nsfw
  }

  @typedoc "user id. used for discord snowflakes"
  @type user_id :: String.t

  @typedoc "username"
  @type username :: String.t

  @typedoc "url of the user's avatar"
  @type user_avatar_url :: String.t

  @typedoc "if the user is a mod in the channel or not"
  @type user_moderator :: boolean

  @typedoc "user struct"
  @type user :: %{
    id: user_id,
    name: username,
    avatar: user_avatar_url,
    moderator: user_moderator
  }

  @typedoc "message text contents"
  @type message_text :: String.t

  @typedoc "url of attached image"
  @type message_image_url :: String.t

  @typedoc "message id. used for discord snowflakes"
  @type message_id :: String.t

  @typedoc "message struct"
  @type message :: %{
    id: message_id,
    text: message_text,
    image: message_image_url
  }

  @enforce_keys [:protocol, :channel, :user, :message]
  defstruct [
    protocol: "unknown",
    guild: %{id: nil, name: "unknown"},
    channel: %{
      id: nil,
      name: "unknown",
      private: false,
      nsfw: false
    },
    user: %{
      id: nil,
      name: "unknown",
      avatar: nil,
      moderator: false
    },
    message: %{
      id: nil,
      text: nil,
      image: nil
    }
  ]
  @type t :: %{
    protocol: protocol,
    guild: guild,
    channel: channel,
    user: user,
    message: message
  }
end