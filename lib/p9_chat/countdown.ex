defmodule P9Chat.Countdown do
  use P9Chat.Responder

  alias P9.Countdown

  @rx ~r/^(<@!?\d+>)\s+countdown(\s+to)?\s+(.+)\s+in\s+([0-9]+)(\s+days)?\s*/i

  @impl true
  def match(msg) do
    String.match?(msg.content, @rx) &&
      Bot.is_bot_mention?(msg)
  end

  @impl true
  def interact(msg) do
    Logger.info("countdown requested")
    [_, _, _, desc, days_txt, _] = Regex.run(@rx, msg.content)

    with {:ok, days} <- parse_days(days_txt),
         {:ok, c} <- Countdown.set(channel_id: msg.channel_id, message: desc, count: days) do
      reply(msg, countdown_msg(c))
      :ack
    else
      {:error, err} ->
        reply(msg, error_msg(err))
        :error
    end
  end

  defp parse_days(raw) do
    case Integer.parse(raw) do
      {num, _} ->
        {:ok, num}

      :error ->
        {:error, "cannot parse `#{raw}` as integer"}
    end
  end
end
