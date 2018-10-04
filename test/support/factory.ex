defmodule Pyromoney.Factory do
  @moduledoc """
  ExMachina-powered factories for tests.
  """

  use ExMachina.Ecto, repo: Pyromoney.Repo

  alias Pyromoney.Accounts.{Account, Type}

  def account_factory do
    %Account{
      name: sequence(:name, &"Account #{&1}"),
      type: sequence(:type, Type.values()),
      currency: "USD",
      virtual: false,
      hidden: false
    }
  end
end
