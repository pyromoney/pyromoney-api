defmodule PyromoneyWeb.TransactionControllerTest do
  use PyromoneyWeb.ConnCase

  import Pyromoney.Factory

  alias Ecto.UUID

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "GET /accounts/:account_id/transactions" do
    test "lists all transactions related to the account", %{conn: conn} do
      wallet_account = insert(:account, type: :cash)
      food_account = insert(:account, type: :expense)
      books_account = insert(:account, type: :expense)

      %{splits: [split_1, split_2]} =
        transaction_1 = transaction_between(wallet_account, food_account, 15.50)

      %{splits: [split_3, split_4]} =
        transaction_2 = transaction_between(wallet_account, books_account, 19.99)

      response =
        conn
        |> get(account_transaction_path(conn, :index, wallet_account))
        |> json_response(200)

      assert response == %{
               "data" => [
                 %{
                   "id" => transaction_1.id,
                   "description" => transaction_1.description,
                   "timestamp" => DateTime.to_iso8601(transaction_1.timestamp),
                   "splits" => [
                     %{
                       "id" => split_1.id,
                       "account_id" => wallet_account.id,
                       "description" => split_1.description,
                       "amount" => "-15.5"
                     },
                     %{
                       "id" => split_2.id,
                       "account_id" => food_account.id,
                       "description" => split_2.description,
                       "amount" => "15.5"
                     }
                   ]
                 },
                 %{
                   "id" => transaction_2.id,
                   "description" => transaction_2.description,
                   "timestamp" => DateTime.to_iso8601(transaction_2.timestamp),
                   "splits" => [
                     %{
                       "id" => split_3.id,
                       "account_id" => wallet_account.id,
                       "description" => split_3.description,
                       "amount" => "-19.99"
                     },
                     %{
                       "id" => split_4.id,
                       "account_id" => books_account.id,
                       "description" => split_4.description,
                       "amount" => "19.99"
                     }
                   ]
                 }
               ]
             }
    end

    test "returns an empty list for unknown account", %{conn: conn} do
      response =
        conn
        |> get(account_transaction_path(conn, :index, UUID.generate()))
        |> json_response(200)

      assert response == %{"data" => []}
    end
  end

  describe "POST /transactions" do
    test "creates new transaction", %{conn: conn} do
      %{id: wallet_account_id} = insert(:account, type: :cash)
      %{id: food_account_id} = insert(:account, type: :expense)

      payload = %{
        transaction: %{
          description: "Shopping",
          timestamp: "2018-10-14T20:36:38Z",
          splits: [
            %{
              account_id: wallet_account_id,
              amount: "-100.50"
            },
            %{
              account_id: food_account_id,
              amount: "100.50"
            }
          ]
        }
      }

      response =
        conn
        |> post(transaction_path(conn, :create), payload)
        |> json_response(201)

      assert %{
               "data" => %{
                 "id" => _,
                 "description" => "Shopping",
                 "timestamp" => "2018-10-14T20:36:38Z",
                 "splits" => [
                   %{
                     "id" => _,
                     "account_id" => wallet_account_id,
                     "description" => nil,
                     "amount" => "-100.50"
                   },
                   %{
                     "id" => _,
                     "account_id" => food_account_id,
                     "description" => nil,
                     "amount" => "100.50"
                   }
                 ]
               }
             } = response
    end

    test "renders errors when data is invalid", %{conn: conn} do
      payload = %{
        transaction: %{
          description: "Shopping"
        }
      }

      response =
        conn
        |> post(transaction_path(conn, :create), payload)
        |> json_response(422)

      assert response == %{
               "errors" => %{"splits" => ["can't be blank"], "timestamp" => ["can't be blank"]}
             }
    end
  end
end
