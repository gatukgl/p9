defmodule P9Discord.Consumer do
  require Logger
  use Nostrum.Consumer

  alias P9Discord.Bot
  alias P9Discord.Controller

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    Bot.ensure_self_aware()
    result = Controller.interact(msg)

    if result == :ignore do
      Logger.debug("ignored message #{msg.content}")
      :ignore
    end

    result
  end

  def handle_event({:READY, guild, _ws_state}) do
    _ = Bot.impersonate(guild.user)
    :ignore
  end

  def handle_event({action, _msg, _ws_state}) do
    Logger.debug("ignored #{action}")
    :ignore
  end
end
