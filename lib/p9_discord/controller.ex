defmodule P9Discord.Controller do
  require Logger
  require Regex

  @responders [
    P9Chat.Allow,
    P9Chat.BulkTrimHistory,
    P9Chat.CanIMod,
    P9Chat.ColorMe,
    P9Chat.Countdown,
    P9Chat.Forget,
    P9Chat.Hello,
    P9Chat.Invite,
    P9Chat.Kudo,
    P9Chat.LeaveMonitor,
    P9Chat.Remember,
    P9Chat.ResetPermissions,
    P9Chat.Search,
    P9Chat.Stat,
    P9Chat.Timeout,
    P9Chat.TrimHistory,
    P9Chat.UncolorMe,
    P9Chat.VoiceChan,
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

    case reply do
      :error ->
        Logger.warn("responder #{responder} errored on message #{msg.content}")

      :ack ->
        Logger.info("responder #{responder} responded to #{msg.content}")

      :ignore ->
        Logger.warn("ignored message #{msg.content}")
    end

    reply
  end
end
