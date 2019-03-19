defmodule FreedomAccountWeb.Router do
  use FreedomAccountWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", FreedomAccountWeb do
    pipe_through :api
  end
end
