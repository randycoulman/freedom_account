defmodule FreedomAccountWeb.TransactionLive.Index do
  @moduledoc false
  use FreedomAccountWeb, :live_view

  import FreedomAccountWeb.AccountBar, only: [account_bar: 1]
  import FreedomAccountWeb.AccountTabs, only: [account_tabs: 1]

  alias FreedomAccount.Paging
  alias FreedomAccount.Transactions
  alias FreedomAccount.Transactions.AccountTransaction
  alias FreedomAccountWeb.Layouts
  alias Phoenix.LiveView

  @page_size 10

  @doc false
  @spec page_size :: pos_integer()
  def page_size, do: @page_size

  @impl LiveView
  def handle_params(_params, _url, socket) do
    socket
    |> assign(:page_title, "Transactions")
    |> load_transactions()
    |> noreply()
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.account_bar account={@account} balance={@account_balance} return_to="transactions" />
      <.account_tabs
        active={:transactions}
        funds_balance={@funds_balance}
        loans_balance={@loans_balance}
      />
      <.table
        id="account-transactions"
        row_click={&JS.navigate(~p"/transactions/#{&1}/edit?#{%{type: &1.type}}")}
        row_id={&"txn-#{&1.type}-#{&1.id}"}
        rows={@transactions}
      >
        <:col :let={transaction} align={:center} class="w-10" label="Type">
          <.icon name={type_icon(transaction)} />
        </:col>
        <:col :let={transaction} class="w-30" label="Date">{transaction.date}</:col>
        <:col :let={transaction} class="w-auto" label="Memo">{transaction.memo}</:col>
        <:col :let={transaction} class="w-50" label="Fund/Loan">{transaction}</:col>
        <:col :let={transaction} align={:right} class="w-28" label="Out">
          <span :if={Money.negative?(transaction.amount)} data-role="out">
            {Money.negate!(transaction.amount)}
          </span>
        </:col>
        <:col :let={transaction} align={:right} class="w-28" label="In">
          <span :if={Money.positive?(transaction.amount)} data-role="in">
            {transaction.amount}
          </span>
        </:col>
        <:col :let={transaction} align={:right} class="w-32" label="Balance">
          {transaction.running_balance}
        </:col>
        <:action :let={transaction}>
          <.link
            class="link link-hover"
            data-confirm="Are you sure?"
            phx-click={
              JS.push("delete", value: %{id: transaction.id, type: transaction.type})
              |> hide("#txn-#{transaction.id}")
            }
          >
            <.icon name="hero-trash-micro" /> <span class="sr-only">Delete</span>
          </.link>
        </:action>
        <:empty_state>
          <div id="no-transactions">
            This account has no transactions yet.
          </div>
        </:empty_state>
      </.table>
      <.button
        disabled={is_nil(@paging.prev_cursor)}
        phx-click="prev-page"
        phx-disable-with="Loading..."
        type="button"
      >
        <.icon name="hero-arrow-left-circle-mini" /> Previous Page
      </.button>
      <.button
        disabled={is_nil(@paging.next_cursor)}
        phx-click="next-page"
        phx-disable-with="Loading..."
        type="button"
      >
        Next Page <.icon name="hero-arrow-right-circle-mini" />
      </.button>
    </Layouts.app>
    """
  end

  defp type_icon(%AccountTransaction{name: "Multiple", type: :fund} = transaction) do
    if Money.negative?(transaction.amount) do
      "hero-folder-minus"
    else
      "hero-folder-plus"
    end
  end

  defp type_icon(%AccountTransaction{type: :fund} = transaction) do
    if Money.negative?(transaction.amount) do
      "hero-minus-circle"
    else
      "hero-plus-circle"
    end
  end

  defp type_icon(%AccountTransaction{type: :loan} = transaction) do
    if Money.negative?(transaction.amount) do
      "hero-credit-card"
    else
      "hero-banknotes"
    end
  end

  @impl LiveView
  def handle_event("delete", %{"id" => id, "type" => "fund"}, socket) do
    with {:ok, transaction} <- Transactions.fetch_transaction(id),
         :ok <- Transactions.delete_transaction(transaction) do
      noreply(socket)
    else
      {:error, error} ->
        socket
        |> put_flash(:error, Exception.message(error))
        |> noreply()
    end
  end

  def handle_event("delete", %{"id" => id, "type" => "loan"}, socket) do
    with {:ok, transaction} <- Transactions.fetch_loan_transaction(id),
         :ok <- Transactions.delete_loan_transaction(transaction) do
      noreply(socket)
    else
      {:error, error} ->
        socket
        |> put_flash(:error, Exception.message(error))
        |> noreply()
    end
  end

  def handle_event("next-page", _params, socket) do
    %{account: account, paging: paging} = socket.assigns

    {transactions, %Paging{} = next_paging} =
      Transactions.list_account_transactions(account, next_cursor: paging.next_cursor, per_page: @page_size)

    socket
    |> assign(:paging, next_paging)
    |> assign(:transactions, transactions)
    |> noreply()
  end

  def handle_event("prev-page", _params, socket) do
    %{account: account, paging: paging} = socket.assigns

    {transactions, %Paging{} = next_paging} =
      Transactions.list_account_transactions(account, prev_cursor: paging.prev_cursor, per_page: @page_size)

    socket
    |> assign(:paging, next_paging)
    |> assign(:transactions, transactions)
    |> noreply()
  end

  @impl LiveView
  def handle_info({event, _transaction}, socket)
      when event in [
             :loan_transaction_created,
             :loan_transaction_deleted,
             :loan_transaction_updated,
             :transaction_created,
             :transaction_deleted,
             :transaction_updated
           ] do
    socket
    |> load_transactions()
    |> noreply()
  end

  def handle_info(_event, socket), do: noreply(socket)

  defp load_transactions(socket) do
    %{account: account} = socket.assigns
    {transactions, %Paging{} = paging} = Transactions.list_account_transactions(account, per_page: @page_size)

    socket
    |> assign(:paging, paging)
    |> assign(:transactions, transactions)
  end
end
