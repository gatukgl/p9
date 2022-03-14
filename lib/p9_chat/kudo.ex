defmodule P9Chat.Kudo do
  use P9Chat.Responder

  require Logger

  alias Nostrum.Api

  @rx ~r/^<@!?(\d+)>\s+(kudos?|thanks?|thxs?)\s*/i
  @ratelimit_seconds 60 * 60 * 24

  @impl true
  def match(msg) do
    String.match?(msg.content, @rx) &&
      !Bot.is_bot_mention?(msg)
  end

  @impl true
  def interact(msg) do
    [_, raw_receiver_user_id, _] = Regex.run(@rx, msg.content)
    {receiver_user_id, _} = Integer.parse(raw_receiver_user_id)

    with :pass <- ratelimit(msg.author.id),
         {:ok, _} <- P9.Kudo.record(msg.author.id, receiver_user_id) do
      {:ok} = Api.create_reaction(msg.channel_id, msg.id, "📝")
      :ack
    else
      :ratelimited ->
        {:ok} = Api.create_reaction(msg.channel_id, msg.id, "⏱")
        :ack

      {:error, err} ->
        reply(msg, error_msg(err))
        :error
    end
  end

  @spec ratelimit(Integer.t()) :: :pass | :ratelimited
  defp ratelimit(giver_user_id) do
    recent = P9.Kudo.get_recent(giver_user_id)

    if recent == nil do
      :pass
    else
      {:ok, inserted_at} = DateTime.from_naive(recent.inserted_at, "Etc/UTC")
      {:ok, now} = DateTime.now("Etc/UTC")

      seconds_apart = DateTime.diff(now, inserted_at, :second)

      if seconds_apart < @ratelimit_seconds do
        :ratelimited
      else
        :pass
      end
    end
  end
end
