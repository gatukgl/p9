defmodule P9Chat.Forget do
  use P9Chat.Responder

  alias P9.Knowledge

  @rx ~r/^(<@!?\d+>)\s+forget(\s+about)?\s+(.+)\s*/i

  @impl true
  def match(msg) do
    String.match?(msg.content, @rx) &&
      Bot.is_bot_mention?(msg)
  end

  @impl true
  def interact(msg) do
    Logger.info("knowledge erased")
    [_, _, _, key] = Regex.run(@rx, msg.content)

    case Knowledge.del(key) do
      {:ok, k} ->
        reply(msg, purge_msg(k.key))
        :ack

      {:error, err} ->
        reply(msg, error_msg(err))
        :error
    end
  end
end
