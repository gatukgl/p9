defmodule P9Chat.CanIMod do
  use P9Chat.Responder

  @rx ~r/\s*can\s+i\s+mod\??\s*/i

  @impl true
  def match(msg), do: String.match?(msg.content, @rx)

  @impl true
  def interact(msg) do
    case author_can_mod?(msg) do
      {:ok, true} ->
        reply(msg, "YOU CAN MOD")
        :ack

      {:ok, false} ->
        reply(msg, "YOU CAN **NOT** MOD")
        :ack

      {:error, err} ->
        reply(msg, error_msg(err))
        :error
    end
  end
end
