defmodule FreedomAccountWeb.AccountBar.Show do
  @moduledoc false

  use FreedomAccountWeb, :live_component

  import FreedomAccountWeb.AccountBar.Form, only: [settings_form: 1]
  import FreedomAccountWeb.ActivationForm, only: [activation_form: 1]
  import FreedomAccountWeb.BudgetForm, only: [budget_form: 1]
  import FreedomAccountWeb.RegularDepositForm, only: [regular_deposit_form: 1]
  import FreedomAccountWeb.TransactionForm, only: [transaction_form: 1]

  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Transactions.Transaction
  alias Phoenix.LiveComponent
  alias Phoenix.LiveView
  alias Phoenix.LiveView.Socket

  attr :account, Account, required: true
  attr :action, :string, required: true
  attr :balance, Money, required: true
  attr :funds, :list, required: true

  @spec account_bar(Socket.assigns()) :: LiveView.Rendered.t()
  def account_bar(assigns) do
    ~H"""
    <.live_component id={@account.id} module={__MODULE__} {assigns} />
    """
  end

  @impl LiveComponent
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:return_path, ~p"/funds")}
  end

  @impl LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <.link navigate={~p"/funds"}><%= @account.name %></.link>
        <span><%= @balance %></span>
        <:actions>
          <.link patch={~p"/funds/regular_deposit"} phx-click={JS.push_focus()}>
            <.button>
              <.icon name="hero-folder-plus-mini" /> Regular Deposit
            </.button>
          </.link>
          <.link patch={~p"/funds/regular_withdrawal"} phx-click={JS.push_focus()}>
            <.button>
              <.icon name="hero-folder-minus-mini" /> Regular Withdrawal
            </.button>
          </.link>
          <.link patch={~p"/funds/budget"} phx-click={JS.push_focus()}>
            <.button>
              <.icon name="hero-chart-pie-mini" /> Budget
            </.button>
          </.link>
          <.link patch={~p"/funds/activate"} phx-click={JS.push_focus()}>
            <.button>
              <.icon name="hero-archive-box-mini" /> Activate/Deactivate
            </.button>
          </.link>
          <.link patch={~p"/funds/account"} phx-click={JS.push_focus()}>
            <.button>
              <.icon name="hero-cog-8-tooth-mini" /> Settings
            </.button>
          </.link>
        </:actions>
      </.header>

      <.modal :if={@action == :activate} id="activate-modal" show on_cancel={JS.patch(@return_path)}>
        <.activation_form account={@account} return_path={@return_path} />
      </.modal>
      <.modal
        :if={@action == :edit_account}
        id="account-modal"
        show
        on_cancel={JS.patch(@return_path)}
      >
        <.settings_form account={@account} funds={@funds} return_path={@return_path} />
      </.modal>

      <.modal :if={@action == :edit_budget} id="budget-modal" show on_cancel={JS.patch(@return_path)}>
        <.budget_form account={@account} funds={@funds} return_path={@return_path} />
      </.modal>

      <.modal
        :if={@action == :regular_deposit}
        id="regular-deposit-modal"
        show
        on_cancel={JS.patch(@return_path)}
      >
        <.regular_deposit_form account={@account} funds={@funds} return_path={@return_path} />
      </.modal>

      <.modal
        :if={@action == :regular_withdrawal}
        id="regular-withdrawal-modal"
        show
        on_cancel={JS.patch(@return_path)}
      >
        <.transaction_form
          account={@account}
          action={@action}
          all_funds={@funds}
          initial_funds={@funds}
          return_path={@return_path}
          transaction={%Transaction{}}
        />
      </.modal>
    </div>
    """
  end
end
