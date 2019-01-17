defmodule PyromoneyWeb.TransactionController do
  use PyromoneyWeb, :controller

  alias Pyromoney.Payments
  alias Pyromoney.Payments.Transaction

  action_fallback(PyromoneyWeb.FallbackController)

  def index(conn, %{"account_id" => account_id}) do
    transactions = Payments.list_transactions(account_id)
    render(conn, "index.json", transactions: transactions)
  end

  def create(conn, %{"transaction" => transaction_params}) do
    with {:ok, %Transaction{} = transaction} <- Payments.create_transaction(transaction_params) do
      conn
      |> put_status(:created)
      |> render("show.json", transaction: transaction)
    end
  end
end
