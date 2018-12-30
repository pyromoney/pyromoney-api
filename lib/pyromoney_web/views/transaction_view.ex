defmodule PyromoneyWeb.TransactionView do
  use PyromoneyWeb, :view
  alias PyromoneyWeb.{SplitView, TransactionView}

  def render("index.json", %{transactions: transactions}) do
    %{data: render_many(transactions, TransactionView, "transaction.json")}
  end

  def render("transaction.json", %{transaction: %{splits: splits} = transaction}) do
    transaction
    |> Map.take(~w(id description timestamp)a)
    |> Map.put(:splits, render_many(splits, SplitView, "split.json"))
  end
end
