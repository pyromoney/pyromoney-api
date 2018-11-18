defmodule Pyromoney.Payments.BalanceValidation do
  @moduledoc """
  Validation rule for balance in each currency separately.
  """

  import Ecto.Changeset

  alias Ecto.Changeset
  alias Pyromoney.Accounts

  @zero Decimal.new(0)

  @doc false
  def validate_balance(%Changeset{} = changeset) do
    validate_change(changeset, :splits, fn :splits, splits ->
      if balanced?(splits), do: [], else: [splits: "are not balanced"]
    end)
  end

  defp balanced?(splits) when is_list(splits) do
    accounts_to_currencies = accounts_to_currencies(splits)

    splits
    |> Enum.group_by(&get_currency(&1, accounts_to_currencies))
    |> Enum.all?(&balanced?/1)
  end

  defp balanced?({_currency, splits}) do
    splits
    |> Enum.map(&get_field(&1, :amount))
    |> Enum.reduce(@zero, &Decimal.add(&1, &2))
    |> Decimal.equal?(@zero)
  end

  defp accounts_to_currencies(splits) do
    splits
    |> Enum.map(fn split -> get_field(split, :account_id) end)
    |> Enum.reject(&is_nil/1)
    |> Accounts.list_accounts()
    |> Enum.map(fn %{id: id, currency: currency} -> {id, currency} end)
    |> Map.new()
  end

  defp get_currency(split, accounts_to_currencies) do
    account_id = get_field(split, :account_id)
    Map.get(accounts_to_currencies, account_id)
  end
end
