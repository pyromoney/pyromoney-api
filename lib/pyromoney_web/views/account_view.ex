defmodule PyromoneyWeb.AccountView do
  use PyromoneyWeb, :view
  alias PyromoneyWeb.AccountView

  def render("index.json", %{accounts: accounts}) do
    %{data: render_many(accounts, AccountView, "account.json")}
  end

  def render("account.json", %{account: account}) do
    Map.take(account, ~w(id parent_id name type currency hidden virtual)a)
  end
end
