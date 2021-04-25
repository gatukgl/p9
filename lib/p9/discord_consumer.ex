defmodule P9.DiscordConsumer do
  require Logger
  use Nostrum.Consumer

  alias P9.DiscordBot, as: Bot
  alias P9.DiscordInteractions, as: Interact

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    Bot.ensure_self_aware

    if Bot.is_bot_mention?(msg) do
      Interact.with(msg)
    else
      :ignore
    end
  end

  def handle_event({:READY, guild, _ws_state}) do
    _ = Bot.impersonate(guild.user)
    :ignore
  end

  def handle_event({action, _msg, _ws_state}) do
    Logger.debug("action #{action}")
    :ignore
  end
end
