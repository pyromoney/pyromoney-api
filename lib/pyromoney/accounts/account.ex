defmodule Pyromoney.Accounts.Account do
  use Ecto.Schema

  import Ecto.Changeset

  alias __MODULE__
  alias Pyromoney.Accounts.Type

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "accounts" do
    field(:name, :string)
    field(:type, Type)
    field(:currency, :string)
    field(:virtual, :boolean, default: false)
    field(:hidden, :boolean, default: false)

    belongs_to(:parent, Account)
    has_many(:children, Account)

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:parent_id, :name, :type, :currency, :hidden, :virtual])
    |> validate_required([:name, :type, :currency])
    |> validate_inclusion(:type, Type.values())
    |> validate_currency()
    |> foreign_key_constraint(:parent_id)
    |> validate_parent()
  end

  defp validate_currency(changeset) do
    validate_change(changeset, :currency, fn :currency, currency ->
      with {:ok, _} <- Money.validate_currency(currency) do
        []
      else
        {:error, {_, error}} -> [currency: error]
      end
    end)
  end

  defp validate_parent(%{data: %{id: nil}} = changeset), do: changeset

  defp validate_parent(%{data: %{id: id}} = changeset) do
    validate_change(changeset, :parent_id, fn
      :parent_id, ^id -> [parent_id: "can't be linked to itself"]
      :parent_id, _ -> []
    end)
  end
end
