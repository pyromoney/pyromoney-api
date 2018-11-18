defmodule Pyromoney.Payments do
  @moduledoc """
  The Payments context.

  This module is responsible for CRUD actions with transactions and splits.
  """

  alias Pyromoney.Payments.Transaction
  alias Pyromoney.Repo

  @doc """
  Creates a new transaction.

  Transaction should be balanced in each currency separately.

  ## Examples

    iex> create_transaction(%{
      description: "Shopping",
      timestamp: "2018-10-14T20:36:38Z",
      splits: [
        %{
          account_id: "dff480b3-20d9-4f43-a148-6fa9fddc2d98",
          amount: "-100.50"
        },
        %{
          account_id: "31108a74-9480-4207-9c5c-bf19fa283310",
          amount: "100.50"
        }
      ]
    })
    {:ok, %Transaction{}}

    iex> create_transaction(%{})
    {:error, %Ecto.Changeset{}}
  """
  def create_transaction(attrs) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end
end
