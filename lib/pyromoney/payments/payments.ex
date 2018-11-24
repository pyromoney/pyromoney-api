defmodule Pyromoney.Payments do
  @moduledoc """
  The Payments context.

  This module is responsible for CRUD actions with transactions and splits.
  """

  import Ecto.Query

  alias Pyromoney.Payments.Transaction
  alias Pyromoney.Repo

  @doc """
  Returns list of transactions related to the specified account id, sorted by the timestamp.

  ## Examples

    iex> list_transaction("dff480b3-20d9-4f43-a148-6fa9fddc2d98")
    [
      %Transaction{
        description: "Shopping",
        timestamp: "2018-10-14T20:36:38Z",
        splits: [
          %Split{
            account_id: "dff480b3-20d9-4f43-a148-6fa9fddc2d98",
            amount: "-100.50"
          },
          %Split{
            account_id: "31108a74-9480-4207-9c5c-bf19fa283310",
            amount: "100.50"
          }
        ]
      }
    ]

    iex> iex> list_transaction("c2be25ef-b8b7-413c-b5fb-6dbba6a64182")
    []
  """
  def list_transactions(account_id) do
    Repo.all(
      from(
        transaction in Transaction,
        join: split in assoc(transaction, :splits),
        where: split.account_id == ^account_id,
        order_by: [asc: :timestamp],
        preload: :splits
      )
    )
  end

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
