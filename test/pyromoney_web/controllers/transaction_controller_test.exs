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

  describe "PATCH /transactions/:id" do
    test "updates transaction and its splits", %{conn: conn} do
      %{
        id: id,
        splits: [
          %{id: split_1_id, account_id: from_account_id},
          %{id: split_2_id, account_id: to_account_id}
        ]
      } = insert(:transaction)

      payload = %{
        transaction: %{
          description: "New description",
          timestamp: "2018-10-14T20:36:38Z",
          splits: [
            %{id: split_1_id, description: "Decrease", amount: "-199.99"},
            %{id: split_2_id, description: "Increase", amount: "199.99"}
          ]
        }
      }

      response =
        conn
        |> patch(transaction_path(conn, :update, id), payload)
        |> json_response(200)

      assert %{
               "data" => %{
                 "id" => id,
                 "description" => "New description",
                 "timestamp" => "2018-10-14T20:36:38Z",
                 "splits" => [
                   %{
                     "id" => split_1_id,
                     "account_id" => from_account_id,
                     "description" => "Decrease",
                     "amount" => "-199.99"
                   },
                   %{
                     "id" => split_2_id,
                     "account_id" => to_account_id,
                     "description" => "Increase",
                     "amount" => "199.99"
                   }
                 ]
               }
             } == response
    end

    test "deletes splits from split transaction", %{conn: conn} do
      %{
        id: id,
        splits: [
          split_1,
          split_2,
          split_3
        ]
      } = transaction = insert(:split_transaction)

      payload = %{
        transaction: %{
          splits: [
            %{id: split_1.id, amount: "-199.99"},
            %{id: split_2.id, delete: true},
            %{id: split_3.id, amount: "199.99"}
          ]
        }
      }

      response =
        conn
        |> patch(transaction_path(conn, :update, id), payload)
        |> json_response(200)

      assert %{
               "data" => %{
                 "id" => id,
                 "description" => transaction.description,
                 "timestamp" => DateTime.to_iso8601(transaction.timestamp),
                 "splits" => [
                   %{
                     "id" => split_1.id,
                     "account_id" => split_1.account_id,
                     "description" => split_1.description,
                     "amount" => "-199.99"
                   },
                   %{
                     "id" => split_3.id,
                     "account_id" => split_3.account_id,
                     "description" => split_3.description,
                     "amount" => "199.99"
                   }
                 ]
               }
             } == response
    end

    test "adds new splits to the transaction", %{conn: conn} do
      %{
        id: id,
        splits: [
          %{id: split_1_id},
          %{id: split_2_id}
        ]
      } = insert(:transaction)

      %{id: other_account_id} = insert(:account)

      payload = %{
        transaction: %{
          splits: [
            %{id: split_1_id, amount: "-100.00"},
            %{id: split_2_id, amount: "70.00"},
            %{amount: "30.00", account_id: other_account_id}
          ]
        }
      }

      response =
        conn
        |> patch(transaction_path(conn, :update, id), payload)
        |> json_response(200)

      assert %{
               "data" => %{
                 "id" => id,
                 "splits" => [
                   %{
                     "id" => split_1_id,
                     "amount" => "-100.00"
                   },
                   %{
                     "id" => split_2_id,
                     "amount" => "70.00"
                   },
                   %{
                     "id" => _,
                     "account_id" => ^other_account_id,
                     "amount" => "30.00"
                   }
                 ]
               }
             } = response
    end

    test "renders errors when data is invalid", %{conn: conn} do
      %{id: id} = insert(:transaction)

      payload = %{
        transaction: %{
          timestamp: "",
          splits: []
        }
      }

      response =
        conn
        |> patch(transaction_path(conn, :update, id), payload)
        |> json_response(422)

      assert response == %{
               "errors" => %{"splits" => ["is invalid"], "timestamp" => ["can't be blank"]}
             }
    end

    test "returns 404 error when transaction is not found", %{conn: conn} do
      assert_error_sent(404, fn ->
        patch(conn, transaction_path(conn, :update, UUID.generate()), %{transaction: %{}})
      end)
    end
  end
end
