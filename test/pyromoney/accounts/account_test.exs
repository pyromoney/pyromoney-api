defmodule Pyromoney.Accounts.AccountTest do
  use Pyromoney.DataCase

  import Pyromoney.Factory

  alias Ecto.{Changeset, NoResultsError, UUID}
  alias Pyromoney.Accounts
  alias Pyromoney.Accounts.Account

  describe "list_accounts/0" do
    test "returns all accounts" do
      account = insert(:account)

      assert Accounts.list_accounts() == [account]
    end
  end

  describe "list_accounts/1" do
    test "returns all accounts with matching ids" do
      %{id: id_1} = account_1 = insert(:account)
      %{id: id_2} = account_2 = insert(:account)
      _not_matching_account = insert(:account)

      assert Accounts.list_accounts([id_1, id_2]) == [account_1, account_2]
    end

    test "does not duplicate entries" do
      %{id: id} = account = insert(:account)
      assert Accounts.list_accounts([id, id]) == [account]
    end
  end

  describe "get_account/1" do
    test "returns the account with given id" do
      %{id: id} = account = insert(:account)

      assert Accounts.get_account!(id) == account
    end
  end

  describe "create_account/1" do
    test "creates a root account with valid data" do
      params = params_for(:account)

      assert {:ok, %Account{} = account} = Accounts.create_account(params)
      assert account.name == params.name
      assert account.type == params.type
      assert account.currency == params.currency
      assert account.hidden == params.hidden
      assert account.virtual == params.virtual
    end

    test "creates a nested account with valid data" do
      %{id: parent_id} = insert(:account)
      params = params_for(:account, parent_id: parent_id)

      assert {:ok, %Account{} = account} = Accounts.create_account(params)
      assert account.name == params.name
      assert account.type == params.type
      assert account.currency == params.currency
      assert account.hidden == params.hidden
      assert account.virtual == params.virtual
      assert account.parent_id == parent_id
    end

    test "returns error changeset without a name" do
      params = params_for(:account, name: "")

      assert {:error, %Changeset{errors: errors}} = Accounts.create_account(params)
      assert errors == [name: {"can't be blank", [validation: :required]}]
    end

    test "returns error changeset without a type" do
      params = params_for(:account, type: "")

      assert {:error, %Changeset{errors: errors}} = Accounts.create_account(params)
      assert errors == [type: {"can't be blank", [validation: :required]}]
    end

    test "returns error changeset with invalid type" do
      params = params_for(:account, type: :unknown)

      assert {:error, %Changeset{errors: errors}} = Accounts.create_account(params)
      assert errors == [type: {"is invalid", [type: Accounts.Type, validation: :cast]}]
    end

    test "returns error changeset without a currency" do
      params = params_for(:account, currency: "")

      assert {:error, %Changeset{errors: errors}} = Accounts.create_account(params)
      assert errors == [currency: {"can't be blank", [validation: :required]}]
    end

    test "returns error changeset with invalid currency" do
      params = params_for(:account, currency: "SPACE_CREDITS")

      assert {:error, %Changeset{errors: errors}} = Accounts.create_account(params)
      assert errors == [currency: {~s(The currency "SPACE_CREDITS" is invalid), []}]
    end

    test "returns error changeset with non-existent parent" do
      params = params_for(:account, parent_id: UUID.generate())

      assert {:error, %Changeset{errors: errors}} = Accounts.create_account(params)
      assert errors == [parent_id: {"does not exist", []}]
    end
  end

  describe "update_account/2" do
    test "updates the account with valid data" do
      account = insert(:account)
      params = params_for(:account)

      assert {:ok, %Account{} = account} = Accounts.update_account(account, params)
      assert account.name == params.name
      assert account.type == params.type
      assert account.currency == params.currency
      assert account.hidden == params.hidden
      assert account.virtual == params.virtual
    end

    test "updates the parent account" do
      account = insert(:account)
      %{id: parent_id} = insert(:account)
      params = params_for(:account, parent_id: parent_id)

      assert {:ok, %Account{} = account} = Accounts.update_account(account, params)
      assert %{parent_id: ^parent_id} = account
    end

    test "returns error changeset with invalid data" do
      %{id: id, name: name} = account = insert(:account)
      params = params_for(:account, name: "")

      assert {:error, %Changeset{}} = Accounts.update_account(account, params)
      assert %{name: ^name} = Accounts.get_account!(id)
    end

    test "returns error changeset when parent set to itself" do
      %{id: id} = account = insert(:account)
      params = params_for(:account, parent_id: id)

      assert {:error, %Changeset{errors: errors}} = Accounts.update_account(account, params)
      assert errors == [parent_id: {"can't be linked to itself", []}]
    end
  end

  describe "delete_account/1" do
    test "deletes the account" do
      %{id: id} = account = insert(:account)

      assert {:ok, %Account{}} = Accounts.delete_account(account)
      assert_raise NoResultsError, fn -> Accounts.get_account!(id) end
    end
  end
end
