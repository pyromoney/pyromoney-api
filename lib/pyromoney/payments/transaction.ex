defmodule Pyromoney.Payments.Transaction do
  @moduledoc """
  A transaction is an exchange between at least two accounts.

  A single transaction always consists of at least two parts, a from and a to account.
  These parts are called Splits.

  A transaction with only two splits is called a simple transaction.

  A transaction with three or more accounts is called a split transaction.

  This module contains schema, changesets and validations for transactions.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Pyromoney.Payments.{BalanceValidation, Split}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "transactions" do
    field(:description, :string)
    field(:timestamp, :utc_datetime)

    has_many(:splits, Split, on_delete: :delete_all)
    has_many(:accounts, through: [:splits, :account])

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:description, :timestamp])
    |> cast_assoc(:splits, required: true)
    |> validate_required([:timestamp])
    |> BalanceValidation.validate_balance()
  end
end
