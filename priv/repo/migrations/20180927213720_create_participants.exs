defmodule Ledger.Repo.Migrations.CreateParticipants do
  use Ecto.Migration

  def change do
    create table(:participants) do
      add :username, :string
      add :amount, :integer
      add :group_id, references(:groups, on_delete: :nothing)

      timestamps()
    end

    create index(:participants, [:group_id])
  end
end
