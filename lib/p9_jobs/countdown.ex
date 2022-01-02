defmodule P9Jobs.Countdown do
  use P9.Scheduler

  require Logger

  alias Nostrum.Api

  @check_interval 60 * 60 * 1000

  def run() do
    # ...
  end
end
