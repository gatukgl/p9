defmodule P9Chat.UncolorMe do
  use P9Chat.Responder

  alias Nostrum.Api

  @rx ~r/^(<@!?\d+>)\s+uncolor(\s+me)?\s+/i

  @impl true
  def match(msg), do: String.match?(msg.content, @rx)

  @impl true
  def interact(msg) do
    Logger.info("removing user color")

    with {:ok, roles} <- Api.get_guild_roles(msg.guild_id),
         {:ok, member} <- Api.get_guild_member(msg.guild_id, msg.author.id),
         # !!! make sure we have all info before we start making changes
         {:ok} <- clear_color_roles(msg, roles, member) do
      reply(msg, "CLEARED COLOR ROLES")
      :ack
    else
      {:error, err} ->
        reply(msg, error_msg(err))
        :error
    end
  end

  # clear_color_roles/3 remove all existing roles prefixed with "COLOR /" from the
  # membership
  defp clear_color_roles(msg, roles, member) do
    roles
    |> Enum.filter(&String.starts_with?(&1.name, "COLOR /"))
    |> Enum.filter(fn r -> nil != Enum.find(member.roles, &(&1 == r.id)) end)
    |> Enum.map(
      &Api.remove_guild_member_role(
        msg.guild_id,
        msg.author.id,
        &1.id,
        "clearing old color roles to assign a new one"
      )
    )
    |> Enum.find({:ok}, &(elem(&1, 0) == :error))
  end
end
