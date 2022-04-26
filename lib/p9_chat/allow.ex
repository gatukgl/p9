defmodule P9Chat.Allow do
  use P9Chat.Responder

  require Protocol

  alias Nostrum.Api
  alias Nostrum.Struct.Overwrite
  Protocol.derive(Jason.Encoder, Overwrite)

  @rx ~r/\s*allow\s+(.+)\s+(to )?(here|react|read|write)\s*/i
  @regular_perm_bits 1_002_911_948_352
  @react_perm_bits 691_526_813_248

  @impl true
  def match(msg) do
    String.match?(msg.content, @rx) &&
      Bot.is_bot_mention?(msg) &&
      {:ok, true} == author_can_mod?(msg)
  end

  @impl true
  def interact(msg) do
    [_, role_name_rx, _, perms] = Regex.run(@rx, msg.content)

    bits =
      case perms do
        "here" ->
          @regular_perm_bits

        "write" ->
          @regular_perm_bits

        "read" ->
          @react_perm_bits

        "react" ->
          @react_perm_bits
      end

    with {:ok, matched_roles} <- find_matched_roles(msg.guild_id, role_name_rx),
         {:ok, channel} = Api.get_channel(msg.channel_id) do
      names =
        matched_roles
        |> Enum.map(& &1.name)
        |> Enum.join("\n")

      overwrites =
        matched_roles
        |> Enum.map(&%Overwrite{id: &1.id, allow: bits, type: 0})

      modifications = %{
        permission_overwrites: channel.permission_overwrites ++ overwrites
      }

      case Api.modify_channel(
             msg.channel_id,
             modifications,
             "Done on behalf of #{msg.author.username}"
           ) do
        {:ok, _} ->
          names = names |> Enum.map(&escape_role_name/1)
          reply(msg, "ALLOWED:\n#{names}")
          :ack

        {:error, err} ->
          reply(msg, error_msg(err))
          :error
      end
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

  defp escape_role_name(name) do
    name |> String.replace("@", "")
  end
end
