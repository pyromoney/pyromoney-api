defmodule Pyromoney.Factory do
  use ExMachina.Ecto, repo: Pyromoney.Repo

  alias Pyromoney.Accounts

  def account_factory do
    %Accounts.Account{
      name: sequence(:name, &"Account #{&1}"),
      type: sequence(:type, Accounts.Type.values()),
      currency: "USD",
      virtual: false,
      hidden: false
    }
  end
end
