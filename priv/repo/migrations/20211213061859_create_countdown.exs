defmodule P9.Repo.Migrations.CreateCountdown do
  use Ecto.Migration

  def change do
    create table(:countdown) do
      add(:channel_id, :bigint, null: false)
      add(:message, :string, null: false)
      add(:count, :integer, null: false)
      timestamps(null: false)
    end
  end
end
