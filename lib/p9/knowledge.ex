defmodule P9.Knowledge do
  require Protocol
  require Logger

  use Ecto.Schema

  alias Ecto.Changeset
  alias P9.Repo

  @derive {Jason.Encoder, only: ~w(key value inserted_at updated_at)a}
  schema "knowledge" do
    field(:key, :string)
    field(:value, :string)
    timestamps()
  end

  def changeset(k, params \\ %{}) do
    k
    |> Changeset.cast(params, [:key, :value])
    |> Changeset.validate_required([:key, :value])
  end

  def get(key) do
    P9.Knowledge
    |> Repo.get_by(key: key)
  end

  def get_all do
    P9.Knowledge
    |> Repo.all()
  end

  def set(key, value) do
    %P9.Knowledge{key: key, value: value}
    |> changeset()
    |> Repo.insert(
      on_conflict: [set: [value: value]],
      conflict_target: :key
    )
  end

  def del(key) do
    P9.Knowledge
    |> Repo.get_by(key: key)
    |> case do
      nil -> {:error, :not_found}
      k -> Repo.delete(k)
    end
  end
end
