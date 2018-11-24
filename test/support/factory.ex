defmodule Pyromoney.Factory do
  @moduledoc """
  ExMachina-powered factories for tests.
  """

  use ExMachina.Ecto, repo: Pyromoney.Repo

  alias Pyromoney.Accounts.{Account, Type}
  alias Pyromoney.Payments.{Split, Transaction}

  def account_factory do
    %Account{
      name: sequence(:name, &"Account #{&1}"),
      type: sequence(:type, Type.values()),
      currency: "USD",
      virtual: false,
      hidden: false
    }
  end

  def split_no_transaction_factory do
    %Split{
      description: sequence(:description, &"Split #{&1}"),
      amount: Decimal.new(10.0),
      account: build(:account)
    }
  end

  def transaction_factory do
    %Transaction{
      description: sequence(:description, &"Transaction #{&1}"),
      timestamp: DateTime.utc_now(),
      splits: [
        build(:split_no_transaction, amount: Decimal.new(-10.0)),
        build(:split_no_transaction, amount: Decimal.new(10.0))
      ]
    }
  end

  def transaction_between(from_account, to_account, amount \\ 10.0) do
    insert(:transaction,
      splits: [
        build(:split_no_transaction, account: from_account, amount: Decimal.new(-amount)),
        build(:split_no_transaction, account: to_account, amount: Decimal.new(amount))
      ]
    )
  end
end
