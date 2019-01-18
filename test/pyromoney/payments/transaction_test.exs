defmodule Pyromoney.Payments.TransactionTest do
  use Pyromoney.DataCase

  import Pyromoney.Factory

  alias Ecto.{Changeset, UUID}
  alias Pyromoney.Payments
  alias Pyromoney.Payments.{Split, Transaction}

  describe "list_transactions/1" do
    test "returns a list of transactions related to the account" do
      wallet_account = insert(:account, type: :cash)
      bank_account = insert(:account, type: :bank)
      food_account = insert(:account, type: :expense)
      books_account = insert(:account, type: :expense)

      %{id: transaction_1} = transaction_between(wallet_account, food_account)
      %{id: transaction_2} = transaction_between(wallet_account, books_account)
      %{id: transaction_3} = transaction_between(bank_account, food_account)

      assert [
               %Transaction{id: ^transaction_1, splits: [_, _]},
               %Transaction{id: ^transaction_2, splits: [_, _]}
             ] = Payments.list_transactions(wallet_account.id)

      assert [
               %Transaction{id: ^transaction_3, splits: [_, _]}
             ] = Payments.list_transactions(bank_account.id)

      assert [
               %Transaction{id: ^transaction_1, splits: [_, _]},
               %Transaction{id: ^transaction_3, splits: [_, _]}
             ] = Payments.list_transactions(food_account.id)

      assert [
               %Transaction{id: ^transaction_2, splits: [_, _]}
             ] = Payments.list_transactions(books_account.id)
    end
  end

  describe "create_transaction/1" do
    @description "Shopping"
    @timestamp "2018-10-14T20:36:38Z"

    test "creates a simple transaction" do
      [%{id: from_id}, %{id: to_id}] = insert_list(2, :account)

      assert {:ok, transaction} =
               Payments.create_transaction(%{
                 description: @description,
                 timestamp: @timestamp,
                 splits: [
                   %{
                     account_id: from_id,
                     amount: "-100.50"
                   },
                   %{
                     account_id: to_id,
                     amount: "100.50"
                   }
                 ]
               })

      assert %Transaction{
               id: id,
               description: @description,
               timestamp: date_time,
               splits: [
                 %Split{
                   transaction_id: id,
                   account_id: ^from_id,
                   amount: from_amount,
                   description: nil
                 },
                 %Split{
                   transaction_id: id,
                   account_id: ^to_id,
                   amount: to_amount,
                   description: nil
                 }
               ]
             } = transaction

      assert {:ok, ^date_time, 0} = DateTime.from_iso8601(@timestamp)
      assert from_amount == Decimal.new("-100.50")
      assert to_amount == Decimal.new("100.50")
    end

    test "creates a split transaction in multiple currencies" do
      %{id: usd_account_id} = insert(:account, currency: "USD", type: :asset)
      %{id: cad_account_id} = insert(:account, currency: "CAD", type: :expense)
      %{id: usd_trading_account_id} = insert(:account, currency: "USD", type: :trading)
      %{id: cad_trading_account_id} = insert(:account, currency: "CAD", type: :trading)

      assert {:ok, transaction} =
               Payments.create_transaction(%{
                 description: @description,
                 timestamp: @timestamp,
                 splits: [
                   %{account_id: usd_account_id, amount: "-100.00"},
                   %{account_id: cad_account_id, amount: "131.00"},
                   %{account_id: usd_trading_account_id, amount: "100.00"},
                   %{account_id: cad_trading_account_id, amount: "-131.00"}
                 ]
               })

      assert %Transaction{
               id: id,
               description: @description,
               timestamp: date_time,
               splits: [
                 %Split{
                   transaction_id: id,
                   account_id: ^usd_account_id,
                   amount: usd_withdrawal,
                   description: nil
                 },
                 %Split{
                   transaction_id: id,
                   account_id: ^cad_account_id,
                   amount: cad_expense,
                   description: nil
                 },
                 %Split{
                   transaction_id: id,
                   account_id: ^usd_trading_account_id,
                   amount: usd_trading_increase,
                   description: nil
                 },
                 %Split{
                   transaction_id: id,
                   account_id: ^cad_trading_account_id,
                   amount: cad_trading_decrease,
                   description: nil
                 }
               ]
             } = transaction

      assert {:ok, ^date_time, 0} = DateTime.from_iso8601(@timestamp)
      assert usd_withdrawal == Decimal.new("-100.00")
      assert cad_expense == Decimal.new("131.00")
      assert usd_trading_increase == Decimal.new("100.00")
      assert cad_trading_decrease == Decimal.new("-131.00")
    end

    test "returns error if split transaction is not balanced" do
      %{id: usd_account_id} = insert(:account, currency: "USD", type: :asset)
      %{id: cad_account_id} = insert(:account, currency: "CAD", type: :expense)
      %{id: usd_trading_account_id} = insert(:account, currency: "USD", type: :trading)
      %{id: pln_trading_account_id} = insert(:account, currency: "PLN", type: :trading)

      assert {:error, changeset} =
               Payments.create_transaction(%{
                 description: @description,
                 timestamp: @timestamp,
                 splits: [
                   %{account_id: usd_account_id, amount: "-101.00"},
                   %{account_id: cad_account_id, amount: "131.00"},
                   %{account_id: usd_trading_account_id, amount: "100.00"},
                   %{account_id: pln_trading_account_id, amount: "-131.00"}
                 ]
               })

      assert %Changeset{errors: [splits: {"are not balanced", []}]} = changeset
    end

    test "returns error without timestamp" do
      [%{id: from_id}, %{id: to_id}] = insert_list(2, :account)

      assert {:error, changeset} =
               Payments.create_transaction(%{
                 description: @description,
                 splits: [
                   %{
                     account_id: from_id,
                     amount: "-100.50"
                   },
                   %{
                     account_id: to_id,
                     amount: "100.50"
                   }
                 ]
               })

      assert %Changeset{
               errors: [timestamp: {"can't be blank", [validation: :required]}]
             } = changeset
    end

    test "returns error with invalid timestamp" do
      [%{id: from_id}, %{id: to_id}] = insert_list(2, :account)

      assert {:error, changeset} =
               Payments.create_transaction(%{
                 description: @description,
                 timestamp: "the first of January",
                 splits: [
                   %{
                     account_id: from_id,
                     amount: "-100.50"
                   },
                   %{
                     account_id: to_id,
                     amount: "100.50"
                   }
                 ]
               })

      assert %Changeset{
               errors: [timestamp: {"is invalid", [type: :utc_datetime, validation: :cast]}]
             } = changeset
    end

    test "returns error when transaction is not balanced" do
      [%{id: from_id}, %{id: to_id}] = insert_list(2, :account)

      assert {:error, changeset} =
               Payments.create_transaction(%{
                 description: @description,
                 timestamp: @timestamp,
                 splits: [
                   %{
                     account_id: from_id,
                     amount: "-100.50"
                   },
                   %{
                     account_id: to_id,
                     amount: "200"
                   }
                 ]
               })

      assert %Changeset{errors: [splits: {"are not balanced", []}]} = changeset
    end

    test "returns error when any of the accounts does not exist" do
      %{id: from_id} = insert(:account)

      assert {:error, changeset} =
               Payments.create_transaction(%{
                 description: @description,
                 timestamp: @timestamp,
                 splits: [
                   %{
                     account_id: from_id,
                     amount: "-100.50"
                   },
                   %{
                     account_id: UUID.generate(),
                     amount: "100.50"
                   }
                 ]
               })

      assert %Changeset{errors: [splits: {"are not balanced", []}]} = changeset
    end
  end

  describe "update_transaction/2" do
    @description "New description"
    @timestamp "2018-10-14T20:36:38Z"

    test "updates transaction and its splits" do
      %{
        id: id,
        splits: [
          %{id: split_1_id, account_id: from_account_id},
          %{id: split_2_id, account_id: to_account_id}
        ]
      } = transaction = insert(:transaction)

      attrs = %{
        description: @description,
        timestamp: @timestamp,
        splits: [
          %{id: split_1_id, amount: "-199.99"},
          %{id: split_2_id, amount: "199.99"}
        ]
      }

      assert {:ok, updated_transaction} = Payments.update_transaction(transaction, attrs)

      assert %Transaction{
               id: ^id,
               description: @description,
               timestamp: date_time,
               splits: [
                 %{id: ^split_1_id, account_id: ^from_account_id, amount: from_amount},
                 %{id: ^split_2_id, account_id: ^to_account_id, amount: to_amount}
               ]
             } = updated_transaction

      assert {:ok, ^date_time, 0} = DateTime.from_iso8601(@timestamp)
      assert from_amount == Decimal.new("-199.99")
      assert to_amount == Decimal.new("199.99")
    end

    test "deletes splits from split transaction" do
      %{
        id: id,
        splits: [
          %{id: split_1_id, account_id: from_account_id},
          %{id: split_2_id, account_id: _},
          %{id: split_3_id, account_id: to_account_id}
        ]
      } = transaction = insert(:split_transaction)

      attrs = %{
        description: @description,
        timestamp: @timestamp,
        splits: [
          %{id: split_1_id, amount: "-199.99"},
          %{id: split_2_id, delete: true},
          %{id: split_3_id, amount: "199.99"}
        ]
      }

      assert {:ok, updated_transaction} = Payments.update_transaction(transaction, attrs)

      assert %Transaction{
               id: ^id,
               splits: [
                 %{id: ^split_1_id, account_id: ^from_account_id, amount: from_amount},
                 %{id: ^split_3_id, account_id: ^to_account_id, amount: to_amount}
               ]
             } = updated_transaction

      assert from_amount == Decimal.new("-199.99")
      assert to_amount == Decimal.new("199.99")
    end

    test "adds new splits to the transaction" do
      %{
        id: id,
        splits: [
          %{id: split_1_id, account_id: from_account_id},
          %{id: split_2_id, account_id: to_account_id}
        ]
      } = transaction = insert(:transaction)

      %{id: other_account_id} = insert(:account)

      attrs = %{
        splits: [
          %{id: split_1_id, amount: "-100.00"},
          %{id: split_2_id, amount: "70.00"},
          %{amount: "30.00", account_id: other_account_id}
        ]
      }

      assert {:ok, updated_transaction} = Payments.update_transaction(transaction, attrs)

      assert %Transaction{
               id: ^id,
               splits: [
                 %{id: ^split_1_id, account_id: ^from_account_id, amount: from_amount},
                 %{id: ^split_2_id, account_id: ^to_account_id, amount: to_amount},
                 %{id: _, account_id: ^other_account_id, amount: other_amount}
               ]
             } = updated_transaction

      assert from_amount == Decimal.new("-100.00")
      assert to_amount == Decimal.new("70.00")
      assert other_amount == Decimal.new("30.00")
    end

    test "returns error when at least one split is not listed in attributes" do
      %{
        splits: [
          %{id: _},
          %{id: split_2_id}
        ]
      } = transaction = insert(:transaction)

      %{id: other_account_id} = insert(:account)

      attrs = %{
        splits: [
          %{id: split_2_id, account_id: other_account_id}
        ]
      }

      assert {:error, changeset} = Payments.update_transaction(transaction, attrs)
      assert %Changeset{errors: [splits: {"is invalid", [type: {:array, :map}]}]} = changeset
    end

    test "returns error when updated transaction is not balanced" do
      %{
        splits: [
          %{id: split_1_id},
          %{id: split_2_id}
        ]
      } = transaction = insert(:transaction)

      attrs = %{
        splits: [
          %{id: split_1_id, amount: "-199.99"},
          %{id: split_2_id, amount: "299.99"}
        ]
      }

      assert {:error, changeset} = Payments.update_transaction(transaction, attrs)
      assert %Changeset{errors: [splits: {"are not balanced", []}]} = changeset
    end
  end
end
