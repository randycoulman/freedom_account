defmodule FreedomAccountWeb.FundLive.Show do
  @moduledoc false
  use FreedomAccountWeb, :live_view

  import FreedomAccountWeb.FundList, only: [fund_list: 1]

  alias FreedomAccount.Funds
  alias FreedomAccount.Transactions
  alias FreedomAccountWeb.FundLive.Form
  alias FreedomAccountWeb.SingleFundTransactionForm
  alias Phoenix.HTML.Safe
  alias Phoenix.LiveView

  @impl LiveView
  def handle_params(%{"id" => id} = params, _url, socket) do
    %{account: account, live_action: action} = socket.assigns

    case Funds.fetch_fund_with_balance(account, id) do
      {:ok, fund} ->
        {:noreply,
         socket
         |> assign(:fund, fund)
         |> apply_action(action, params)}

      {:error, :not_found} ->
        {:noreply,
         socket
         |> put_flash(:error, "Fund not found")
         |> push_navigate(to: ~p"/funds")}
    end
  end

  defp apply_action(socket, :edit, _params) do
    assign(socket, :page_title, "Edit Fund")
  end

  defp apply_action(socket, :edit_account, _params) do
    assign(socket, :page_title, "Edit Account Settings")
  end

  defp apply_action(socket, :edit_budget, _params) do
    assign(socket, :page_title, "Update Budget")
  end

  defp apply_action(socket, :new_deposit, _params) do
    socket
    |> assign(:page_title, "Deposit")
    |> assign(:transaction, Transactions.new_single_fund_transaction(socket.assigns.fund))
  end

  defp apply_action(socket, :new_withdrawal, _params) do
    socket
    |> assign(:page_title, "Withdraw")
    |> assign(:transaction, Transactions.new_single_fund_transaction(socket.assigns.fund))
  end

  defp apply_action(socket, _action, _params) do
    %{fund: fund} = socket.assigns

    assign(socket, :page_title, Safe.to_iodata(fund))
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <.live_component
      account={@account}
      action={@live_action}
      budget_path={~p"/funds/#{@fund}/budget"}
      edit_path={~p"/funds/#{@fund}/account"}
      funds={@funds}
      id={@account.id}
      module={FreedomAccountWeb.Account.Show}
      return_path={~p"/funds/#{@fund}"}
    />
    <div class="flex h-screen">
      <aside class="hidden md:flex flex-col w-56 bg-slate-100">
        <.fund_list funds={@funds} />
      </aside>
      <main class="flex flex-col flex-1 overflow-y-auto pl-2">
        <.header>
          <div class="flex flex-row">
            <span><%= @fund %></span>
            <span><%= @fund.current_balance %></span>
          </div>
          <:subtitle>
            <div class="flex flex-row" id="fund-subtitle">
              <span>Budget: <%= @fund.budget %></span>
              <span>(<%= @fund.times_per_year %> times/year)</span>
            </div>
          </:subtitle>
          <:actions>
            <.link patch={~p"/funds/#{@fund}/show/edit"} phx-click={JS.push_focus()}>
              <.button>
                <.icon name="hero-pencil-square-mini" /> Edit Details
              </.button>
            </.link>
            <.link patch={~p"/funds/#{@fund}/deposits/new"} phx-click={JS.push_focus()}>
              <.button>
                <.icon name="hero-plus-circle-mini" /> Deposit
              </.button>
            </.link>
            <.link patch={~p"/funds/#{@fund}/withdrawals/new"} phx-click={JS.push_focus()}>
              <.button>
                <.icon name="hero-minus-circle-mini" /> Withdraw
              </.button>
            </.link>
          </:actions>
        </.header>

        <.back navigate={~p"/funds"}>Back to Funds</.back>
      </main>
    </div>

    <.modal :if={@live_action == :edit} id="fund-modal" show on_cancel={JS.patch(~p"/funds/#{@fund}")}>
      <.live_component
        account={@account}
        action={@live_action}
        fund={@fund}
        id={@fund.id}
        module={Form}
        patch={~p"/funds/#{@fund}"}
        title={@page_title}
      />
    </.modal>

    <.modal
      :if={@live_action in [:new_deposit, :new_withdrawal]}
      id="transaction-modal"
      show
      on_cancel={JS.patch(~p"/funds/#{@fund}")}
    >
      <.live_component
        action={@live_action}
        fund={@fund}
        id={@transaction.id || :new}
        module={SingleFundTransactionForm}
        patch={~p"/funds/#{@fund}"}
        title={@page_title}
        transaction={@transaction}
      />
    </.modal>
    """
  end
end
