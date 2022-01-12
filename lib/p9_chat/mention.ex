defmodule P9Chat.Mention do
  use P9Chat.Responder

  alias P9.Knowledge

  @rx ~r/^(<@!?\d+>)\s*(.+)\s*/i

  @impl true
  def match(msg) do
    String.match?(msg.content, @rx) &&
      Bot.is_bot_mention?(msg)
  end

  @impl true
  def interact(msg) do
    Logger.info("unknown query: #{msg.content}, checking knowledges.")
    [_, _, key] = Regex.run(@rx, msg.content)

    case Knowledge.get(key) do
      nil ->
        reply(msg, dontknow_msg(key))
        :ignore

      k ->
        reply(msg, knowledge_msg(k))
        :ack
    end
  end
end
