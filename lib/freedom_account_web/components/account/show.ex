defmodule FreedomAccountWeb.Account.Show do
  @moduledoc false

  use FreedomAccountWeb, :live_component

  alias FreedomAccountWeb.Account.Form
  alias FreedomAccountWeb.BudgetForm
  alias FreedomAccountWeb.RegularDepositForm
  alias Phoenix.LiveComponent

  @impl LiveComponent
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @account.name %>
        <:actions>
          <.link patch={@regular_deposit_path} phx-click={JS.push_focus()}>
            <.button>
              <.icon name="hero-folder-plus-mini" /> Regular Deposit
            </.button>
          </.link>
          <.link patch={@budget_path} phx-click={JS.push_focus()}>
            <.button>
              <.icon name="hero-chart-pie-mini" /> Budget
            </.button>
          </.link>
          <.link patch={@edit_path} phx-click={JS.push_focus()}>
            <.button>
              <.icon name="hero-cog-8-tooth-mini" /> Settings
            </.button>
          </.link>
        </:actions>
      </.header>

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
    </div>
    """
  end
end
