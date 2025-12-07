defmodule FreedomAccountWeb.Router do
  use FreedomAccountWeb, :router

  alias FreedomAccountWeb.Hooks

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {FreedomAccountWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FreedomAccountWeb do
    pipe_through :browser

    get "/", HomeController, :redirect_to_fund_list

    live_session :default, on_mount: Hooks.LoadInitialData do
      live "/account/edit", AccountLive.Form, :edit

      live "/funds", FundLive.Index, :index
      live "/funds/new", FundLive.Index, :new
      live "/funds/:id/edit", FundLive.Index, :edit
      live "/funds/regular_withdrawal", FundLive.Index, :regular_withdrawal

      live "/funds/activate", FundLive.ActivationForm, :activate
      live "/funds/budget", FundLive.BudgetForm, :edit
      live "/funds/regular_deposit", FundLive.RegularDepositForm, :regular_deposit

      live "/funds/:id", FundLive.Show, :show
      live "/funds/:id/show/edit", FundLive.Show, :edit
      live "/funds/:id/deposits/new", FundLive.Show, :deposit
      live "/funds/:id/withdrawals/new", FundLive.Show, :withdrawal
      live "/funds/:id/transactions/:transaction_id/edit", FundLive.Show, :edit_transaction

      live "/loans", LoanLive.Index, :index
      live "/loans/new", LoanLive.Index, :new
      live "/loans/:id/edit", LoanLive.Index, :edit

      live "/loans/activate", LoanLive.ActivationForm, :activate

      live "/loans/:id", LoanLive.Show, :show
      live "/loans/:id/show/edit", LoanLive.Show, :edit
      live "/loans/:id/loans/new", LoanLive.Show, :lend
      live "/loans/:id/payments/new", LoanLive.Show, :payment
      live "/loans/:id/transactions/:transaction_id/edit", LoanLive.Show, :edit_transaction

      live "/transactions", TransactionLive.Index, :index
      live "/transactions/:id/edit", TransactionLive.Index, :edit_transaction
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", FreedomAccountWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:freedom_account, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: FreedomAccountWeb.Telemetry
    end
  end
end
