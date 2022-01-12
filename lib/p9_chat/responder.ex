defmodule P9Chat.Responder do
  require Logger

  alias Nostrum.Struct.Message
  alias Nostrum.Api

  @doc false
  defmacro __using__(_opts) do
    quote do
      @behaviour P9Chat.Responder

      require Logger

      import P9Chat.Responder

      alias P9Discord.Bot
    end
  end

  @callback match(Message.t()) :: boolean()
  @callback interact(Message.t()) :: :ack | :ignore | :error

  @spec reply(Message.t(), String.t()) :: :ack | :ignore | :error
  def reply(msg, content) do
    case Api.create_message(msg.channel_id,
           content: content,
           message_reference: %{message_id: msg.id}
         ) do
      {:ok, _} ->
        :ack

      {:error, err} ->
        Logger.error(err)
        :error
    end
  end

  @spec author_can_mod?(Message.t()) :: {:ok, boolean()} | {:error, any()}
  def author_can_mod?(msg) do
    with {:ok, roles} <- Api.get_guild_roles(msg.guild_id),
         {:ok, member} <- Api.get_guild_member(msg.guild_id, msg.author.id) do
      id_maps =
        roles
        |> Enum.map(&{&1.id, &1.name})
        |> Map.new()

      mod_role =
        member.roles
        |> Enum.map(&Map.get(id_maps, &1))
        |> Enum.filter(&(&1 != nil))
        |> Enum.filter(fn role ->
          String.contains?(role, "MODERATOR") ||
            String.contains?(role, "CHIEF")
        end)
        |> List.first()

      {:ok, mod_role != nil}
    else
      {:error, err} ->
        {:error, err}
    end
  end

  def purge_msg(k), do: "PURGED RECORD OF `#{k}`"
  def dontknow_msg(k), do: "NO RECORD OF `#{k}`"
  def error_msg(err), do: "ERROR!\n```\n#{err.response.message}\n```"

  def knowledge_msg(k) do
    uri = URI.parse(k.value)

    if uri.scheme == nil do
      "`#{k.key}` = `#{k.value}`"
    else
      "`#{k.key}` = #{k.value}"
    end
  end

  def countdown_msg(c) do
    "it is #{c.count} days until #{c.message}"
  end

  def result_msg(query, result) do
    result
    |> Enum.map(fn k -> knowledge_msg(k) end)
    |> Enum.reduce("RESULT MATCHING `#{query}`", fn s, acc -> acc <> "\n" <> s end)
  end
end
