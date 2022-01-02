defmodule P9.Countdown do
  require Logger
  require Protocol

  use Ecto.Schema

  alias Ecto.Changeset
  alias P9.Repo

  schema "countdown" do
    field(:channel_id, :integer)
    field(:message, :string)
    field(:count, :integer)
    timestamps()
  end

  def changeset(k, params \\ %{}) do
    k
    |> Changeset.cast(params, [:channel_id, :message, :count])
    |> Changeset.validate_required([:channel_id, :message, :count])
  end

  def get_all do
    P9.Countdown
    |> Repo.all()
  end

  def set(channel_id: cid, message: msg, count: count) do
    %P9.Countdown{
      channel_id: cid,
      message: msg,
      count: count
    }
    |> changeset()
    |> Repo.insert()
  end
end
