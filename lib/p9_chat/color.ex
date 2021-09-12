defmodule P9Chat.Color do
  use P9Chat.Responder

  @type t :: {:ok, Atom.t()}

  alias Nostrum.Api

  @rx ~r/^(<@!?\d+>)\s+color(\s+me)?\s+(.+)\s*/i

  @impl true
  def match(msg), do: String.match?(msg.content, @rx)

  @impl true
  def interact(msg) do
    Logger.info("changing user color")
    [_, _, _, alpha] = Regex.run(@rx, msg.content)

    target_role_name = "COLOR / #{String.upcase(alpha)}"

    with {:ok, roles} <- Api.get_guild_roles(msg.guild_id),
         {:ok, member} <- Api.get_guild_member(msg.guild_id, msg.author.id),
         {:ok, target_role} <- find_target_role(roles, target_role_name),
         # !!! make sure we have all info before we start making changes
         {:ok} <- clear_color_roles(msg, roles, member),
         {:ok} <- Api.add_guild_member_role(msg.guild_id, msg.author.id, target_role.id) do
      reply(
        msg,
        "ASSIGNED `#{target_role.name}` = `##{Integer.to_string(target_role.color, 16)}`"
      )

      :ack
    else
      {:error, err} ->
        reply(msg, error_msg(err))
        :error
    end
  end

  # find_target_role/2 turns Enum.find result in {:ok}, {:error} pair so we can match `with`
  defp find_target_role(roles, name) do
    case Enum.find(roles, &(&1.name == name)) do
      nil ->
        {:error, "no role #{name}"}

      role ->
        {:ok, role}
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
