defmodule P9.Kudo do
  require Logger
  use Ecto.Schema

  alias Ecto.Changeset
  alias P9.Repo

  import Ecto.Query

  @derive {Jason.Encoder, only: ~w()a}
  schema "kudo" do
    field(:giver_user_id, :integer)
    field(:receiver_user_id, :integer)
    timestamps()
  end

  def changeset(k, params \\ %{}) do
    k
    |> Changeset.cast(params, [:giver_user_id, :receiver_user_id])
    |> Changeset.validate_required([:giver_user_id, :receiver_user_id])
  end

  def get_recent(giver_user_id) do
    from(k in P9.Kudo, order_by: [desc: :inserted_at], limit: 1)
    |> Repo.get_by(%{giver_user_id: giver_user_id})
  end

  def count_received(receiver_user_id) do
    from(k in P9.Kudo, where: k.receiver_user_id == ^receiver_user_id)
    |> Repo.aggregate(:count, :inserted_at)
  end

  def record(giver_user_id, receiver_user_id) do
    %P9.Kudo{
      giver_user_id: giver_user_id,
      receiver_user_id: receiver_user_id
    }
    |> changeset()
    |> Repo.insert()
  end
end
