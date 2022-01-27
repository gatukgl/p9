defmodule P9Chat.Leave do
  use P9Chat.Responder

  alias Nostrum.Api

  # @leave_channel_id 833_014_615_587_028_992
  @leave_channel_id 836_114_039_851_188_275

  @impl true
  def match(msg) do
    # is #leave channel and did not mention anyone
    msg.channel_id == @leave_channel_id &&
      msg.referenced_message == nil &&
      !Bot.is_bot_msg?(msg)
  end

  @impl true
  def interact(msg) do
    mention_someone =
      msg.mention_everyone ||
        length(msg.mention_roles) > 0 ||
        length(msg.mentions) > 0

    if !mention_someone do
      reply(
        msg,
        "Please mention your team or your manager\nMake sure they leave a :white_check_mark:"
      )

      :ack
    else
      case Api.create_reaction(msg.channel_id, msg.id, "✅") do
        {:ok} ->
          :ack

        {:error, err} ->
          reply(msg, error_msg(err))
          :error
      end
    end
  end
end
