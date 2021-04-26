defmodule P9Discord.Supervisor do
  require Logger

  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    children = [
      {P9Discord.Bot, []},
      {P9Discord.Consumer, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
