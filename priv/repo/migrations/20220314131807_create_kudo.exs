defmodule P9.Repo.Migrations.CreateKudo do
  use Ecto.Migration

  def change do
    create table(:kudo) do
      add(:giver_user_id, :bigint, null: false)
      add(:receiver_user_id, :bigint, null: false)
      timestamps(null: false)
    end
  end
end
