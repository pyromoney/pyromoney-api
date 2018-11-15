defmodule Pyromoney.Repo.Migrations.CreateSplits do
  use Ecto.Migration

  def change do
    create table(:splits, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:description, :string)
      add(:amount, :numeric)

      add(:transaction_id, references(:transactions, on_delete: :delete_all, type: :binary_id),
        null: false
      )

      add(:account_id, references(:accounts, on_delete: :restrict, type: :binary_id), null: false)

      timestamps()
    end

    create(index(:splits, [:transaction_id]))
    create(index(:splits, [:account_id]))
  end
end
