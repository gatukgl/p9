# bulk-delete version of TrimHistory
# doesn't exactly work correctly as discord bulk-delete api has a 2-weeks limit
defmodule P9Chat.BulkTrimHistory do
  use P9Chat.Responder
  require Logger

  alias Nostrum.Api
  alias Nostrum.Struct.Message

  @rx ~r/^(<@!?\d+>)\s+bulk\s+trim\s+history\s*/i
  @history_limit 60 * 60 * 24
  @bulk_delete_limit 100

  @impl true
  def match(msg) do
    Bot.is_bot_mention?(msg) &&
      String.match?(msg.content, @rx) &&
      {:ok, true} == author_can_mod?(msg)
  end

  @impl true
  def interact(msg) do
    {:ok, now} = DateTime.now("Etc/UTC")
    boundary = DateTime.add(now, -1 * @history_limit, :second)

    with {:ok, boundary_msg} <- find_most_recent_after(boundary, [msg]),
         {:ok, count} <- trim_messages_before(boundary_msg) do
      reply(boundary_msg, "TRIMMED #{count} MESSAGES BEFORE THIS ONE")
      :ack
    else
      {:not_found} ->
        reply(msg, "COULD NOT FIND BOUNDARY")
        :error

      {:error, err} ->
        reply(msg, error_msg(err))
        :error
    end
  end

  defp trim_messages_before(boundary_msg, count \\ 0) do
    case Api.get_channel_messages(boundary_msg.channel_id, :infinity, {:before, boundary_msg.id}) do
      {:ok, []} ->
        {:ok, count}

      {:ok, messages} ->
        case delete_messages(messages) do
          {:ok, deleted} ->
            trim_messages_before(boundary_msg, count + deleted)

          {:error, err} ->
            {:error, err}
        end

      {:error, err} ->
        {:error, err}
    end
  end

  defp delete_messages(messages, count \\ 0) do
    {chunk, leftover} = Enum.split(messages, @bulk_delete_limit)

    case chunk do
      [] ->
        {:ok, count}

      [msg] ->
        case Api.delete_message(msg) do
          {:ok} ->
            {:ok, count + 1}

          {:error, err} ->
            {:error, err}
        end

      [msg | _] ->
        case Api.request(:post, "/channels/#{msg.channel_id}/messages/bulk-delete", %{
               messages: chunk |> Enum.map(fn m -> m.id end)
             }) do
          {:ok} ->
            delete_messages(leftover, count + @bulk_delete_limit)

          {:ok, _} ->
            delete_messages(leftover, count + @bulk_delete_limit)

          {:error, err} ->
            {:error, err}
        end
    end
  end

  defp find_most_recent_after(boundary, buffer) do
    Logger.info("buffer: #{Enum.count(buffer)}")

    case buffer do
      [] ->
        {:error, "Not enough messages to compute, needs at least 1 to start with"}

      [ref_msg] ->
        case Api.get_channel_messages(ref_msg.channel_id, :infinity, {:before, ref_msg.id}) do
          {:ok, messages} ->
            new_buffer = [ref_msg | messages] |> Enum.sort_by(fn m -> m.id end, :desc)

            if Enum.count(new_buffer) <= 1 do
              {:not_found}
            else
              find_most_recent_after(boundary, new_buffer)
            end

          {:error, err} ->
            {:error, err}
        end

      # work to find a pair {a, b} where the boundary is exactly between them
      # then we have our "most recent" message being a
      # (since b is first one to exceed boundary)
      [msg_a | [msg_b | tail]] ->
        Logger.info("boundary:\n#{msg_a.timestamp} > #{boundary} > #{msg_b.timestamp}")

        if DateTime.compare(msg_a.timestamp, boundary) == :gt &&
             DateTime.compare(boundary, msg_b.timestamp) == :gt do
          # Logger.info("found: #{msg_a.content}")
          {:ok, msg_a}
        else
          find_most_recent_after(boundary, [msg_b | tail])
        end
    end
  end
end
