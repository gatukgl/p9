defmodule P9Chat.CanIMod do
  use P9Chat.Responder

  alias Nostrum.Api

  @rx ~r/\s*can\s+i\s+mod\??\s*/i

  @impl true
  def match(msg), do: String.match?(msg.content, @rx)

  @impl true
  def interact(msg) do
    with {:ok, roles} <- Api.get_guild_roles(msg.guild_id),
         {:ok, member} <- Api.get_guild_member(msg.guild_id, msg.author.id) do
      id_maps =
        roles
        |> Enum.map(&{&1.id, &1.name})
        |> Map.new()

      is_mod =
        member.roles
        |> Enum.map(&Map.get(id_maps, &1))
        |> Enum.filter(&(&1 != nil))
        |> Enum.filter(fn role ->
          String.contains?(role, "MODERATOR") ||
            String.contains?(role, "CHIEF")
        end)
        |> List.first()

      if is_mod do
        reply(msg, "YOU CAN MOD")
      else
        reply(msg, "YOU CAN **NOT** MOD")
      end

      :ack
    else
      {:error, err} ->
        reply(msg, error_msg(err))
        :error
    end
  end
end
