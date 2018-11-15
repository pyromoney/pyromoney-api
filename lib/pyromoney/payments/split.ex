defmodule Pyromoney.Payments.Split do
  @moduledoc """
  Split is a part of transaction. Every transaction has at least two splits,
  but a transaction can have more than two splits.

  This module contains schema, changesets and validations for transaction splits.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Pyromoney.Accounts.Account
  alias Pyromoney.Payments.Transaction

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "splits" do
    field(:description, :string)
    field(:amount, :decimal)

    belongs_to(:transaction, Transaction)
    belongs_to(:account, Account)

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:account_id, :amount, :description])
    |> validate_required([:account_id, :amount])
    |> assoc_constraint(:transaction)
    |> assoc_constraint(:account)
  end
end
