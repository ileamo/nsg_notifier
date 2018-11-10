defmodule NsgNotifierWeb.Router do
  use NsgNotifierWeb, :router

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

  scope "/", NsgNotifierWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/delete", PageController, :delete)
    get("/config", ConfigController, :edit)
    post("/config", ConfigController, :update)
  end

  scope "/api", NsgNotifierWeb.Api, as: :api do
    pipe_through(:api)
    post("/", EventController, :index)
  end

  # Other scopes may use custom stacks.
  # scope "/api", NsgNotifierWeb do
  #   pipe_through :api
  # end
end
