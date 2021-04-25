defmodule P9 do
  @moduledoc false

  require Logger

  use Application

  @impl true
  def start(_type, _args) do
    Logger.info("descending into pandemonium...")
    P9.Supervisor.start_link(name: P9.Supervisor)
  end

  @impl true
  def prep_stop(_state) do
    Logger.info("preparing to stop...")
    :ok
  end

  @impl true
  def stop(_state) do
    Logger.info("stopped.")
    :ok
  end
end
