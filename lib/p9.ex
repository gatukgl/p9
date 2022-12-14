defmodule P9 do
  @moduledoc false

  require Logger

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {P9.Repo, []},
      {P9.Scheduler, []},
      {P9Discord.Bot, []},
      {P9Discord.Consumer, []},
      {P9Web.Endpoint, []},
      {Finch, name: P9Finch}
    ]

    Logger.info("P9 Bot Starting...")

    Supervisor.start_link(children,
      name: P9Supervisor,
      strategy: :one_for_one
    )
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
