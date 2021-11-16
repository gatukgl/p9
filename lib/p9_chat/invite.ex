defmodule P9Chat.Invite do
  use P9Chat.Responder

  alias Nostrum.Api

  @rx ~r/^(<@!?\d+>)\s+invite\s+(.+)\s*/i
  @lobby_id 783_003_481_958_383_629

  @impl true
  def match(msg), do: String.match?(msg.content, @rx)

  @impl true
  def interact(msg) do
    Logger.info("generating discord invite")
    [_, _, email] = Regex.run(@rx, msg.content)

    case Api.create_channel_invite(@lobby_id, max_uses: 1, unique: true) do
      {:ok, invite} ->
        email = P9.DiscordEmail.single_invitation(email, invite.code)

        case P9.Mailer.deliver!(email) do
          {:ok, _} ->
            reply(msg, "INVITATION SENT")
            :ack

          {:error, err} ->
            reply(msg, error_msg(err))
            :error
        end

      {:error, err} ->
        reply(msg, error_msg(err))
        :error
    end
  end
end
