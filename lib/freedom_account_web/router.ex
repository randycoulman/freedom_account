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
      live "/account/edit", AccountLive.Form

      live "/funds", FundLive.Index
      live "/funds/new", FundLive.Form, :new

      live "/funds/activate", FundLive.ActivationForm
      live "/funds/budget", FundLive.BudgetForm
      live "/funds/regular_deposit", FundLive.RegularDepositForm
      live "/funds/regular_withdrawal", FundLive.RegularWithdrawalForm

      live "/funds/:id", FundLive.Show
      live "/funds/:id/edit", FundLive.Form, :edit

      live "/funds/:id/deposits/new", FundLive.DepositForm
      live "/funds/:id/transactions/:transaction_id/edit", FundLive.TransactionForm
      live "/funds/:id/withdrawals/new", FundLive.WithdrawalForm

      live "/loans", LoanLive.Index
      live "/loans/new", LoanLive.Form, :new

      live "/loans/activate", LoanLive.ActivationForm

      live "/loans/:id", LoanLive.Show
      live "/loans/:id/edit", LoanLive.Form, :edit

      live "/loans/:id/loans/new", LoanLive.LoanForm
      live "/loans/:id/payments/new", LoanLive.PaymentForm
      live "/loans/:id/transactions/:transaction_id/edit", LoanLive.TransactionForm

      live "/transactions", TransactionLive.Index

      live "/transactions/:id/edit", TransactionLive.TransactionForm
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
