defmodule P9Chat.TrimHistory do
  use P9Chat.Responder
  require Logger

  alias Nostrum.Api
  alias Nostrum.Struct.Message

  @rx ~r/^(<@!?\d+>)\s+trim\s+history\s*/i
  @history_limit 60 * 60 * 24

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

  # we have to delete 1-by-1 since bulk delete API doesn't work for messages older than 2
  # weeks
  defp delete_messages(messages, count \\ 0) do
    case messages do
      [] ->
        {:ok, count}

      [msg | rest] ->
        case Api.delete_message(msg.channel_id, msg.id) do
          {:ok} ->
            # nostrum ratelimiter doesn't fucking work
            :timer.sleep(2000)
            delete_messages(rest, count + 1)

          {:error, err} ->
            {:error, err}
        end
    end
  end

  # bulk version: 
  # (but this doesn't work as discord has 2 weeks limit with this API)
  # 
  # defp delete_messages(messages, count \\ 0) do
  #   {chunk, leftover} = Enum.split(messages, @delete_chunk_size)

  #   case chunk do
  #     [] ->
  #       {:ok, count}

  #     [msg] ->
  #       case Api.delete_message(msg) do
  #         {:ok} ->
  #           {:ok, count + 1}

  #         {:error, err} ->
  #           {:error, err}
  #       end

  #     [msg | _] ->
  #       case Api.request(:post, "/channels/#{msg.channel_id}/messages/bulk-delete", %{
  #              messages: chunk |> Enum.map(fn m -> m.id end)
  #            }) do
  #         {:ok, _} ->
  #           delete_messages(leftover, count + @delete_chunk_size)

  #         {:error, err} ->
  #           {:error, err}
  #       end
  #   end
  # end

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
