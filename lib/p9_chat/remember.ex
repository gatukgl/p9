defmodule P9Chat.Remember do
  use P9Chat.Responder

  alias P9.Knowledge

  @rx ~r/^(<@!?\d+>)\s+remember\s+(.+)\s+is\s+(.+)\s*/i

  @impl true
  def match(msg), do: String.match?(msg.content, @rx)

  @impl true
  def interact(msg) do
    Logger.info("knowledge received")
    [_, _, key, value] = Regex.run(@rx, msg.content)

    case Knowledge.set(key, value) do
      {:ok, k} ->
        reply(msg, knowledge_msg(k))
        :ack

      {:error, err} ->
        reply(msg, error_msg(err))
        :error
    end
  end
end
