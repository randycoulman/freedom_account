defmodule FreedomAccountWeb.FundLive.Show do
  @moduledoc false
  use FreedomAccountWeb, :live_view

  import FreedomAccountWeb.Account, only: [account: 1]
  import FreedomAccountWeb.FundLive.Form, only: [settings_form: 1]
  import FreedomAccountWeb.FundTransaction.Index, only: [fund_transaction_list: 1]
  import FreedomAccountWeb.Sidebar, only: [sidebar: 1]
  import FreedomAccountWeb.TransactionForm, only: [transaction_form: 1]

  alias FreedomAccount.Error
  alias FreedomAccount.Error.NotFoundError
  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.Transactions
  alias FreedomAccount.Transactions.Transaction
  alias FreedomAccountWeb.FundTransaction
  alias FreedomAccountWeb.Layouts
  alias Phoenix.HTML.Safe
  alias Phoenix.LiveView

  @impl LiveView
  def handle_params(params, _url, socket) do
    id = String.to_integer(params["id"])
    %{funds: funds, live_action: action} = socket.assigns

    case fetch_fund(funds, id) do
      {:ok, %Fund{} = fund} ->
        socket
        |> assign(:fund, fund)
        |> assign(:transaction, nil)
        |> apply_action(action, params)
        |> noreply()

      {:error, %NotFoundError{}} ->
        socket
        |> put_flash(:error, "Fund not found")
        |> push_navigate(to: ~p"/funds")
        |> noreply()
    end
  end

  defp apply_action(socket, :edit, _params) do
    assign(socket, :page_title, "Edit Fund")
  end

  defp apply_action(socket, :edit_transaction, params) do
    transaction_id = String.to_integer(params["transaction_id"])

    case Transactions.fetch_transaction(transaction_id) do
      {:ok, %Transaction{} = transaction} ->
        socket
        |> assign(:page_title, "Edit Transaction")
        |> assign(:transaction, transaction)

      {:error, %NotFoundError{}} ->
        put_flash(socket, :error, "Transaction is no longer present")
    end
  end

  defp apply_action(socket, :withdrawal, _params) do
    socket
    |> assign(:page_title, "Withdraw")
    |> assign(:transaction, %Transaction{})
  end

  defp apply_action(socket, _action, _params) do
    %{fund: fund} = socket.assigns

    assign(socket, :page_title, Safe.to_iodata(fund))
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.account account={@account} balance={@account_balance} />
      <div class="flex h-screen">
        <aside class="hidden md:flex flex-col w-56 bg-slate-100">
          <.sidebar
            funds={@funds}
            funds_balance={@funds_balance}
            loans={@loans}
            loans_balance={@loans_balance}
          />
        </aside>
        <main class="flex flex-col flex-1 overflow-y-auto pl-2">
          <.header>
            <div class="flex flex-row">
              <span>{@fund}</span>
              <span>{@fund.current_balance}</span>
            </div>
            <:subtitle>
              <div class="flex flex-row" id="fund-subtitle">
                <span>
                  Deposit: {Funds.regular_deposit_amount(@fund, @account)} ({@fund.budget} @ {@fund.times_per_year} times/year)
                </span>
              </div>
            </:subtitle>
            <:actions>
              <.link
                id="single-fund-deposit"
                patch={~p"/funds/#{@fund}/deposits/new"}
                phx-click={JS.push_focus()}
              >
                <.button>
                  <.icon name="hero-plus-circle-mini" /> Deposit
                </.button>
              </.link>
              <.link
                id="single-fund-withdrawal"
                patch={~p"/funds/#{@fund}/withdrawals/new"}
                phx-click={JS.push_focus()}
              >
                <.button>
                  <.icon name="hero-minus-circle-mini" /> Withdraw
                </.button>
              </.link>
              <.link patch={~p"/funds/#{@fund}/show/edit"} phx-click={JS.push_focus()}>
                <.button>
                  <.icon name="hero-pencil-square-mini" /> Edit Details
                </.button>
              </.link>
            </:actions>
          </.header>
          <.fund_transaction_list fund={@fund} id={@fund.id} />

          <.back navigate={~p"/funds"}>Back to Funds</.back>
        </main>
      </div>

      <.modal
        :if={@live_action == :edit}
        id="fund-modal"
        show
        on_cancel={JS.patch(~p"/funds/#{@fund}")}
      >
        <.settings_form
          account={@account}
          action={@live_action}
          fund={@fund}
          return_path={~p"/funds/#{@fund}"}
          title={@page_title}
        />
      </.modal>

      <.modal
        :if={@live_action in [:edit_transaction, :withdrawal]}
        id="transaction-modal"
        show
        on_cancel={JS.patch(~p"/funds/#{@fund}")}
      >
        <.transaction_form
          account={@account}
          action={@live_action}
          all_funds={@funds}
          initial_funds={[@fund]}
          return_path={~p"/funds/#{@fund}"}
          transaction={@transaction}
        />
      </.modal>
    </Layouts.app>
    """
  end

  @impl LiveView
  def handle_info({:funds_updated, funds}, socket) do
    %{fund: fund, live_action: action} = socket.assigns

    case fetch_fund(funds, fund.id) do
      {:ok, %Fund{} = fund} ->
        socket
        |> assign(:fund, fund)
        |> apply_action(action, %{})
        |> noreply()

      {:error, %NotFoundError{}} ->
        noreply(socket)
    end
  end

  def handle_info({:transaction_updated, transaction}, socket) do
    %{fund: fund} = socket.assigns

    if Enum.any?(transaction.line_items, &(&1.fund_id == fund.id)) do
      send_update(FundTransaction.Index, id: fund.id, fund: fund)
    end

    noreply(socket)
  end

  def handle_info(_message, socket), do: noreply(socket)

  defp fetch_fund(funds, id) do
    with %Fund{} = fund <- Enum.find(funds, {:error, Error.not_found(details: %{id: id}, entity: Fund)}, &(&1.id == id)) do
      {:ok, fund}
    end
  end
end
