defmodule Pyromoney.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string, null: false)
      add(:type, :string, null: false)
      add(:currency, :string, null: false)
      add(:hidden, :boolean, default: false, null: false)
      add(:virtual, :boolean, default: false, null: false)

      add(:parent_id, references(:accounts, on_delete: :restrict, type: :binary_id))

      timestamps()
    end

    create(index(:accounts, [:parent_id]))
  end
end
