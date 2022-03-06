defmodule P9Jobs.KeepThreadAlive do
  use P9.Scheduler

  require Logger

  alias Nostrum.Api

  @check_interval 5 * 1000
  @revive_threshold 60 * 60 * 1000

  def run() do
    with {:ok, [guild | _]} <- Api.get_current_user_guilds(),
         {:ok, body} <- Api.request(:get, "/guilds/#{guild.id}/threads/active"),
         {:ok, obj} <- Poison.decode(body, keys: :atoms) do
      obj.threads |> Enum.each(&process_thread/1)
      {@check_interval, :ok}
    else
      {:error, err} ->
        Logger.error("#{__MODULE__} -> #{Kernel.inspect(err)}")
    end
  end

  defp process_thread(thread) do
    with {thread_id, _} <- Integer.parse(thread.id),
         {last_message_id, _} <- Integer.parse(thread.last_message_id),
         {:ok, last_message} <- Api.get_channel_message(thread_id, last_message_id) do
      time_left =
        last_message.timestamp
        |> DateTime.add(thread.thread_metadata.auto_archive_duration * 60, :second)
        |> DateTime.diff(DateTime.utc_now(), :millisecond)

      if time_left < @revive_threshold do
        Logger.info("Thread ##{thread_id} is about to be archived, bumping.")

        Api.create_message(
          thread_id,
          "(autobump), please manually archive this thread if you no longer need to use it."
        )
      end
    else
      {:error, err} ->
        Logger.error("#{__MODULE__} -> #{Kernel.inspect(err)}")
    end
  end
end
