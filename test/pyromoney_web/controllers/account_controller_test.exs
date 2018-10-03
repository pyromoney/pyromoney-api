defmodule PyromoneyWeb.AccountControllerTest do
  use PyromoneyWeb.ConnCase

  import Pyromoney.Factory

  alias Pyromoney.Accounts

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "GET /accounts" do
    test "lists all accounts", %{conn: conn} do
      parent = insert(:account)
      account = insert(:account, parent_id: parent.id)

      response =
        conn
        |> get(account_path(conn, :index))
        |> json_response(200)

      assert response == %{
               "data" => [
                 %{
                   "id" => parent.id,
                   "parent_id" => nil,
                   "name" => parent.name,
                   "type" => Atom.to_string(parent.type),
                   "currency" => parent.currency,
                   "hidden" => parent.hidden,
                   "virtual" => parent.virtual
                 },
                 %{
                   "id" => account.id,
                   "parent_id" => parent.id,
                   "name" => account.name,
                   "type" => Atom.to_string(account.type),
                   "currency" => account.currency,
                   "hidden" => account.hidden,
                   "virtual" => account.virtual
                 }
               ]
             }
    end
  end

  describe "POST /accounts" do
    test "renders created account without parent", %{conn: conn} do
      params = params_for(:account)

      response =
        %{"id" => id} =
        conn
        |> post(account_path(conn, :create), account: params)
        |> json_response(201)

      assert response == %{
               "id" => id,
               "parent_id" => nil,
               "name" => params.name,
               "type" => Atom.to_string(params.type),
               "currency" => params.currency,
               "hidden" => params.hidden,
               "virtual" => params.virtual
             }
    end

    test "renders created account with parent", %{conn: conn} do
      %{id: parent_id} = insert(:account)
      params = params_for(:account, parent_id: parent_id)

      response =
        %{"id" => id} =
        conn
        |> post(account_path(conn, :create), account: params)
        |> json_response(201)

      assert response == %{
               "id" => id,
               "parent_id" => parent_id,
               "name" => params.name,
               "type" => Atom.to_string(params.type),
               "currency" => params.currency,
               "hidden" => params.hidden,
               "virtual" => params.virtual
             }
    end

    test "renders errors when data is invalid", %{conn: conn} do
      params = params_for(:account, name: "")

      response =
        conn
        |> post(account_path(conn, :create), account: params)
        |> json_response(422)

      assert response == %{"errors" => %{"name" => ["can't be blank"]}}
    end
  end

  describe "PATCH /accounts/:id" do
    test "renders account when data is valid", %{conn: conn} do
      %{id: id} = account = insert(:account)
      params = params_for(:account)

      response =
        conn
        |> put(account_path(conn, :update, account), account: params)
        |> json_response(200)

      assert response == %{
               "id" => id,
               "parent_id" => nil,
               "name" => params.name,
               "type" => Atom.to_string(params.type),
               "currency" => params.currency,
               "hidden" => params.hidden,
               "virtual" => params.virtual
             }
    end

    test "renders errors when data is invalid", %{conn: conn} do
      account = insert(:account)
      params = params_for(:account, name: "")

      response =
        conn
        |> put(account_path(conn, :update, account), account: params)
        |> json_response(422)

      assert response == %{"errors" => %{"name" => ["can't be blank"]}}
    end
  end

  describe "DELETE /accounts/:id" do
    test "deletes chosen account", %{conn: conn} do
      %{id: id} = account = insert(:account)

      response =
        conn
        |> delete(account_path(conn, :delete, account))
        |> response(204)

      assert response == ""

      assert_raise Ecto.NoResultsError, fn -> Accounts.get_account!(id) end
    end
  end
end
