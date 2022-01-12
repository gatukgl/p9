defmodule P9Chat.ResetPermissions do
  use P9Chat.Responder

  alias Nostrum.Api

  @rx ~r/\s*reset\s+permissions?\s*/i

  @impl true
  def match(msg) do
    Bot.is_bot_mention?(msg) &&
      String.match?(msg.content, @rx) &&
      {:ok, true} == author_can_mod?(msg)
  end

  @impl true
  def interact(msg) do
    case Api.modify_channel(
           msg.channel_id,
           %{permission_overwrites: []},
           "Done on behalf of #{msg.author.username}"
         ) do
      {:ok, chan} ->
        reply(msg, "RESET PERMISSIONS IN ##{chan.name}")
        :ack

      {:error, err} ->
        reply(msg, error_msg(err))
        :error
    end
  end
end
