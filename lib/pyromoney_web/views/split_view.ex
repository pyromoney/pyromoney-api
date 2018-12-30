defmodule PyromoneyWeb.SplitView do
  use PyromoneyWeb, :view

  def render("split.json", %{split: split}) do
    Map.take(split, ~w(id account_id description amount)a)
  end
end
