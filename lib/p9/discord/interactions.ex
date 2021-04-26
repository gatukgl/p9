defmodule P9.Discord.Interactions do
  require Logger
  require Regex

  alias Nostrum.Api
  alias P9.Domain.Knowledge

  @hello_rx ~r/(<@!?\d+>)\s*hello\s*/i
  @remember_rx ~r/(<@!?\d+>)\s+remember\s+(.+)\s+is\s+(.+)\s*/i
  @forget_rx ~r/(<@!?\d+>)\s+forget(\s+about)?\s+(.+)\s*/i
  @mention_rx ~r/(<@!?\d+>)\s*(.+)\s*/i

  def with(msg) do
    cond do
      String.match?(msg.content, @hello_rx) ->
        Logger.info("greetings received")

        reply(
          msg,
          "A STRANGE GAME.\n" <>
            "THE ONLY WINNING MOVE IS\n" <>
            "NOT TO PLAY."
        )

        :ack

      String.match?(msg.content, @remember_rx) ->
        Logger.info("knowledge received")
        [_, _, key, value] = Regex.run(@remember_rx, msg.content)

        case Knowledge.set(key, value) do
          {:ok, k} ->
            reply(msg, knowledge_msg(k))
            :ack

          {:error, err} ->
            reply(msg, error_msg(err))
            :error
        end

      String.match?(msg.content, @forget_rx) ->
        Logger.info("knowledge erased")
        [_, _, _, key] = Regex.run(@forget_rx, msg.content)

        case Knowledge.del(key) do
          {:ok, k} ->
            reply(msg, purge_msg(k.key))
            :ack

          {:error, err} ->
            reply(msg, error_msg(err))
            :error
        end

      String.match?(msg.content, @mention_rx) ->
        Logger.info("unknown query: #{msg.content}, checking knowledges.")
        [_, _, key] = Regex.run(@mention_rx, msg.content)

        case Knowledge.get(key) do
          nil ->
            reply(msg, dontknow_msg(key))
            :ignore

          k ->
            reply(msg, knowledge_msg(k))
            :ack
        end

      true ->
        Logger.info("ignored message: #{msg.content}")
        :ignore
    end
  end

  defp reply(msg, txt), do: Api.create_message(msg.channel_id, txt)
  defp knowledge_msg(k), do: "`#{k.key}` = `#{k.value}`"
  defp purge_msg(k), do: "PURGED RECORD OF `#{k}`"
  defp dontknow_msg(k), do: "NO RECORD OF `#{k}`"
  defp error_msg(err), do: "ERROR!\n```\n#{err}\n```"
end
