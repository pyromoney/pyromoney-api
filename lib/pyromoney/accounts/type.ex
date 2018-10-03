defmodule Pyromoney.Accounts.Type do
  use Exnumerator, values: [:asset, :cash, :bank, :liability, :income, :expense, :equity]
end
