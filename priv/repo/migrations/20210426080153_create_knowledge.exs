defmodule P9.Repo.Migrations.CreateKnowledge do
  use Ecto.Migration

  def change do
    create table(:knowledge) do
      add :key, :string, null: false
      add :value, :string, null: false
      timestamps null: false
    end
  end
end
