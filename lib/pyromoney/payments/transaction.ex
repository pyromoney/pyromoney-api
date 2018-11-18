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

  alias Pyromoney.Accounts
  alias Pyromoney.Payments.Split

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
    |> validate_balance()
  end

  defp validate_balance(changeset) do
    validate_change(changeset, :splits, fn :splits, splits ->
      if balanced?(splits), do: [], else: [splits: "are not balanced"]
    end)
  end

  defp balanced?(splits) when is_list(splits) do
    splits
    |> Enum.group_by(fn split ->
      split
      |> get_field(:account_id)
      |> Accounts.get_currency()
    end)
    |> Enum.all?(&balanced?/1)
  end

  defp balanced?({_currency, splits}) do
    zero = Decimal.new(0)

    splits
    |> Enum.map(&get_field(&1, :amount))
    |> Enum.reduce(zero, &Decimal.add(&1, &2))
    |> Decimal.equal?(zero)
  end
end
