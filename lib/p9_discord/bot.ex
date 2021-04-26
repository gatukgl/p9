defmodule P9Discord.Bot do
  defmodule State do
    defstruct username: "",
              discriminator: ""
  end

  require Logger

  alias Nostrum.Api

  use GenServer

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %State{}}
  end

  def ensure_self_aware do
    if !is_self_aware?() do
      {:ok, me} = Api.get_current_user()
      {:ok, _} = impersonate(me)
    end

    :ok
  end

  def is_self_aware? do
    GenServer.call(__MODULE__, {:is_self_aware?, []})
  end

  def is_bot_mention?(msg) do
    GenServer.call(__MODULE__, {:is_bot_mention?, msg})
  end

  def impersonate(me) do
    GenServer.call(__MODULE__, {:impersonate, me})
  end

  def handle_call({:is_self_aware?, _}, _, state) do
    aware =
      String.trim(state.username) != "" &&
        String.trim(state.discriminator) != ""

    {:reply, aware, state}
  end

  def handle_call({:impersonate, user}, _, state) do
    Logger.info("interacting as user #{user.username}##{user.discriminator}")

    new_state = %{state | username: user.username, discriminator: user.discriminator}
    {:reply, {:ok, new_state}, new_state}
  end

  def handle_call({:is_bot_mention?, msg}, _, state) do
    match =
      msg.mentions
      |> Enum.any?(fn m ->
        state.username == m.username &&
          state.discriminator == m.discriminator
      end)

    {:reply, match, state}
  end
end
