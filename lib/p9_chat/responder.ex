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
    end
  end

  @callback match(Message.t()) :: boolean()
  @callback interact(Message.t()) :: :ack | :ignore | :error

  @spec reply(Message.t(), String.t()) :: :ack | :ignore | :error
  def reply(msg, content) do
    case Api.create_message(msg.channel_id, content) do
      {:ok, _} ->
        :ack

      {:error, err} ->
        Logger.error(err)
        :error
    end
  end

  def knowledge_msg(k), do: "`#{k.key}` = `#{k.value}`"
  def purge_msg(k), do: "PURGED RECORD OF `#{k}`"
  def dontknow_msg(k), do: "NO RECORD OF `#{k}`"
  def error_msg(err), do: "ERROR!\n```\n#{err}\n```"

  def result_msg(query, result) do
    result
    |> Enum.map(fn k -> knowledge_msg(k) end)
    |> Enum.reduce("RESULT MATCHING `#{query}`", fn s, acc -> acc <> "\n" <> s end)
  end
end
