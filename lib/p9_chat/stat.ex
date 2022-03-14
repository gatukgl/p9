defmodule P9Chat.Stat do
  use P9Chat.Responder

  @rx ~r/^<@!?\d+>\s+stats?\s*/i

  @impl true
  def match(msg) do
    Bot.is_bot_mention?(msg) &&
      String.match?(msg.content, @rx)
  end

  @impl true
  def interact(msg) do
    kudos = P9.Kudo.count_received(msg.author.id)
    reply(msg, "#{kudos} KUDOS RECEIVED")
    :ack
  end
end
