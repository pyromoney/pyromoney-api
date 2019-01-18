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

    belongs_to(:transaction, Transaction, on_replace: :update)
    belongs_to(:account, Account)

    field(:delete, :boolean, virtual: true)

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:account_id, :amount, :description, :delete])
    |> validate_required([:account_id, :amount])
    |> assoc_constraint(:transaction)
    |> assoc_constraint(:account)
    |> maybe_mark_for_deletion()
  end

  defp maybe_mark_for_deletion(changeset) do
    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end
end
