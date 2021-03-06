defmodule Pyromoney.Accounts do
  @moduledoc """
  The Accounts context.

  Account is an entity which contains other sub-accounts, or that contains transactions.
  """

  import Ecto.Query

  alias Pyromoney.Accounts.Account
  alias Pyromoney.Repo

  @doc """
  Returns the list of accounts.

  ## Examples

      iex> list_accounts()
      [%Account{}, ...]

  """
  def list_accounts do
    Repo.all(Account)
  end

  @doc """
  Returns the list of accounts with matching ids.

  ## Examples

      iex> list_accounts(["7564bfe4-5a0b-4c5f-ac23-110afd7b2310", "unknown-id"])
      [%Account{id: "7564bfe4-5a0b-4c5f-ac23-110afd7b2310"}]

  """
  def list_accounts(ids) when is_list(ids) do
    Account
    |> where([account], account.id in ^ids)
    |> Repo.all()
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!("7564bfe4-5a0b-4c5f-ac23-110afd7b2310")
      %Account{}

      iex> get_account!("unknown-id")
      ** (Ecto.NoResultsError)

  """
  def get_account!(id), do: Repo.get!(Account, id)

  @doc """
  Creates an account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(attrs \\ %{}) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates the account.

  ## Examples

      iex> update_account(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes the account.

  ## Examples

      iex> delete_account(account)
      {:ok, %Account{}}

      iex> delete_account(account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end
end
