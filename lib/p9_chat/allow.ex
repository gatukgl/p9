defmodule P9Chat.Allow do
  use P9Chat.Responder

  alias Nostrum.Api
  alias Nostrum.Struct.Overwrite

  @rx ~r/\s*allow\s+(.+)\s+here\s*/i
  @perm_bits 1_071_631_425_088

  @impl true
  def match(msg), do: String.match?(msg.content, @rx)

  @impl true
  def interact(msg) do
    {:ok, true} = author_can_mod?(msg)
    [_, role_name_rx] = Regex.run(@rx, msg.content)

    with {:ok, matched_roles} <- find_matched_roles(msg.guild_id, role_name_rx) do
      names =
        matched_roles
        |> Enum.map(& &1.name)
        |> Enum.join("\n")

      overwrites =
        matched_roles
        |> Enum.map(&%Overwrite{id: &1.id, allow: @perm_bits})

      Api.modify_channel(
        msg.channel_id,
        %{permission_overwrites: overwrites},
        "Done on behalf of #{msg.author.username}"
      )

      reply(msg, "ALLOWED:\n#{names}")
      :ack
    else
      {:error, err} ->
        reply(msg, error_msg(err))
        :error
    end
  end

  defp find_matched_roles(guild_id, role_name_rx) do
    with {:ok, role_rx} <- Regex.compile(role_name_rx),
         {:ok, roles} <- Api.get_guild_roles(guild_id) do
      {:ok, Enum.filter(roles, &String.match?(&1.name, role_rx))}
    else
      {:error, err} ->
        {:error, err}
    end
  end
end
