defmodule FreedomAccountWeb.AccountBar.Show do
  @moduledoc false

  use FreedomAccountWeb, :live_component

  alias FreedomAccountWeb.AccountBar.Form
  alias FreedomAccountWeb.ActivationForm
  alias FreedomAccountWeb.BudgetForm
  alias FreedomAccountWeb.RegularDepositForm
  alias FreedomAccountWeb.TransactionForm
  alias Phoenix.LiveComponent

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
        <.live_component
          account={@account}
          id={@account.id}
          module={ActivationForm}
          return_path={@return_path}
        />
      </.modal>
      <.modal
        :if={@action == :edit_account}
        id="account-modal"
        show
        on_cancel={JS.patch(@return_path)}
      >
        <.live_component
          account={@account}
          action={@action}
          funds={@funds}
          id={@account.id}
          module={Form}
          return_path={@return_path}
        />
      </.modal>

      <.modal :if={@action == :edit_budget} id="budget-modal" show on_cancel={JS.patch(@return_path)}>
        <.live_component
          account={@account}
          action={@action}
          funds={@funds}
          id={@account.id}
          module={BudgetForm}
          return_path={@return_path}
        />
      </.modal>

      <.modal
        :if={@action == :regular_deposit}
        id="regular-deposit-modal"
        show
        on_cancel={JS.patch(@return_path)}
      >
        <.live_component
          account={@account}
          action={@action}
          funds={@funds}
          id={@account.id}
          module={RegularDepositForm}
          return_path={@return_path}
        />
      </.modal>

      <.modal
        :if={@action == :regular_withdrawal}
        id="regular-withdrawal-modal"
        show
        on_cancel={JS.patch(@return_path)}
      >
        <.live_component
          account={@account}
          action={@action}
          funds={@funds}
          id={:new}
          module={TransactionForm}
          return_path={@return_path}
        />
      </.modal>
    </div>
    """
  end
end
