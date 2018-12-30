defmodule PyromoneyWeb.Router do
  use PyromoneyWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", PyromoneyWeb do
    pipe_through(:api)

    resources("/accounts", AccountController, except: [:show, :new, :edit]) do
      resources("/transactions", TransactionController, only: [:index])
    end
  end
end
