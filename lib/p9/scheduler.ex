defmodule P9.Scheduler do
  use GenServer

  require Logger

  @doc false
  defmacro __using__(_opts) do
    quote do
      @behaviour P9.Scheduler

      import P9.Scheduler
    end
  end

  @callback run() :: {integer(), any()}

  @start_delay 3 * 1000
  @check_interval 10 * 1000
  @jobs [
    P9Jobs.KeepThreadAlive
  ]

  def start_link(_opts) do
    init_state = %{
      next_run_at: nil,
      ran_at: nil,
      last_result: nil
    }

    GenServer.start_link(__MODULE__, Map.new(@jobs, &{&1, init_state}))
  end

  def init(state) do
    Logger.info("Scheduler started")
    Process.send_after(self(), :check, @start_delay)
    {:ok, state}
  end

  def handle_info(:check, state) do
    new_state =
      state
      |> Enum.map(&check_mod/1)
      |> Map.new()

    schedule_next()
    {:noreply, new_state, :hibernate}
  end

  defp check_mod({mod, mod_state}) do
    t = DateTime.utc_now()

    if mod_state.next_run_at == nil || DateTime.compare(t, mod_state.next_run_at) == :gt do
      {delay, result} = mod.run()
      next_run = DateTime.add(t, delay, :millisecond)

      {mod,
       %{
         next_run_at: next_run,
         ran_at: t,
         last_result: result
       }}
    else
      {mod, mod_state}
    end
  end

  defp schedule_next() do
    Process.send_after(self(), :check, @check_interval)
  end
end
