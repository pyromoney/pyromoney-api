defmodule Pyromoney.Accounts.Type do
  @moduledoc """
  List of available account types.
  """

  use Exnumerator,
    values: [:asset, :cash, :bank, :liability, :income, :expense, :equity, :trading]
end
