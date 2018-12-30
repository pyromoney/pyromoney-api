defmodule PyromoneyWeb.TransactionController do
  use PyromoneyWeb, :controller

  alias Pyromoney.Payments

  action_fallback(PyromoneyWeb.FallbackController)

  def index(conn, %{"account_id" => account_id}) do
    transactions = Payments.list_transactions(account_id)
    render(conn, "index.json", transactions: transactions)
  end
end
