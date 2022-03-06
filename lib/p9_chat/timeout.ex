defmodule P9Chat.Timeout do
  use P9Chat.Responder
  alias Nostrum.Api

  @rx ~r/^(<@!?\d+>)\s+time\s?out(\s+for)?\s+(.+)?\s*/i
  @period_rx ~r/^\s*(\d+|one|a|an|two)\s+(min|hr|hour|day)s?\s*$/i

  @impl true
  def match(msg) do
    String.match?(msg.content, @rx) &&
      Bot.is_bot_mention?(msg)
  end

  @impl true
  def interact(msg) do
    Logger.info("timeout #{msg.author.username}")
    [_, _, _, raw_duration] = Regex.run(@rx, msg.content)

    with {:ok, seconds} <- calculate_seconds(raw_duration),
         {:ok, now} <- DateTime.now("Etc/UTC"),
         until <- DateTime.add(now, seconds, :second),
         {:ok, _} <-
           Api.modify_guild_member(
             msg.guild_id,
             msg.author.id,
             %{communication_disabled_until: until},
             "Requested through the bot"
           ) do
      reply(msg, "TIMED OUT `#{msg.author.username}` UNTIL `#{until}`")
      :ack
    else
      {:error, err} ->
        reply(msg, error_msg(err))
        :error
    end
  end

  defp calculate_seconds(raw_period) do
    [_, raw_amount, raw_unit] = Regex.run(@period_rx, raw_period)

    raw_amount =
      case raw_amount do
        "one" -> "1"
        "a" -> "1"
        "an" -> "1"
        "two" -> "2"
        _ -> raw_amount
      end

    multiplier =
      case raw_unit do
        "min" -> 60
        "hr" -> 60 * 60
        "hour" -> 60 * 60
        "day" -> 60 * 60 * 24
        _ -> -1
      end

    if {amount, _} = Integer.parse(raw_amount) do
      seconds = amount * multiplier

      if seconds > 0 do
        {:ok, seconds}
      else
        {:error, "couldn't parse duration"}
      end
    else
      {:error, "couldn't parse duration"}
    end
  end
end
