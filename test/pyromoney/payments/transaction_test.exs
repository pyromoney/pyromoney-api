defmodule Pyromoney.Payments.TransactionTest do
  use Pyromoney.DataCase

  import Pyromoney.Factory

  alias Ecto.{Changeset, UUID}
  alias Pyromoney.Payments
  alias Pyromoney.Payments.{Split, Transaction}

  @description "Shopping"
  @timestamp "2018-10-14T20:36:38Z"

  describe "create_transaction/1" do
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

      assert %Changeset{
               changes: %{
                 splits: [
                   %{valid?: true},
                   %{valid?: false, errors: [account: {"does not exist", []}]}
                 ]
               }
             } = changeset
    end
  end
end
