defmodule P9Discord.Controller do
  require Logger
  require Regex

  @responders [
    P9Chat.ColorMe,
    P9Chat.UncolorMe,
    P9Chat.Hello,
    P9Chat.Remember,
    P9Chat.Forget,
    P9Chat.Search,
    P9Chat.Invite,
    P9Chat.CanIMod,
    # mention responder must be last as it globs up everything
    P9Chat.Mention
  ]

  def interact(msg) do
    interact(msg, Enum.find(@responders, & &1.match(msg)))
  end

  def interact(msg, nil) do
    Logger.info("ignoring message: #{msg.content}")
    :ignore
  end

  def interact(msg, responder) do
    Logger.info("responding with #{responder}")
    reply = responder.interact(msg)

    if reply == :error do
      Logger.warn("responder #{responder} errored on message #{msg.content}")
    end

    reply
  end
end
