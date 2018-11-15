defmodule Pyromoney.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:description, :string)
      add(:timestamp, :utc_datetime)

      timestamps()
    end
  end
end
