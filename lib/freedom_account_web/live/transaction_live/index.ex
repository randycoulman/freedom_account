defmodule FreedomAccountWeb.TransactionLive.Index do
  @moduledoc false
  use FreedomAccountWeb, :live_view

  import FreedomAccountWeb.AccountBar.Show, only: [account_bar: 1]
  import FreedomAccountWeb.AccountTabs, only: [account_tabs: 1]
  import FreedomAccountWeb.LoanTransactionForm, only: [loan_transaction_form: 1]
  import FreedomAccountWeb.TransactionForm, only: [transaction_form: 1]

  alias FreedomAccount.Error.NotFoundError
  alias FreedomAccount.Paging
  alias FreedomAccount.Transactions
  alias FreedomAccount.Transactions.AccountTransaction
  alias FreedomAccount.Transactions.LoanTransaction
  alias FreedomAccount.Transactions.Transaction
  alias Phoenix.LiveView

  @page_size 10

  @doc false
  @spec page_size :: pos_integer()
  def page_size, do: @page_size

  @impl LiveView
  def handle_params(params, _url, socket) do
    %{live_action: action} = socket.assigns

    socket
    |> load_transactions()
    |> assign(:loan, nil)
    |> assign(:return_path, ~p"/transactions")
    |> assign(:transaction, nil)
    |> apply_action(action, params)
    |> noreply()
  end

  defp apply_action(socket, :edit_account, _params) do
    assign(socket, :page_title, "Edit Account Settings")
  end

  defp apply_action(socket, :edit_transaction, %{"type" => "fund"} = params) do
    id = String.to_integer(params["id"])

    case Transactions.fetch_transaction(id) do
      {:ok, %Transaction{} = transaction} ->
        socket
        |> assign(:page_title, "Edit Transaction")
        |> assign(:transaction, transaction)

      {:error, %NotFoundError{}} ->
        put_flash(socket, :error, "Transaction is no longer present")
    end
  end

  defp apply_action(socket, :edit_transaction, %{"type" => "loan"} = params) do
    id = String.to_integer(params["id"])

    case Transactions.fetch_loan_transaction(id) do
      {:ok, %LoanTransaction{} = transaction} ->
        loan = find_loan(socket.assigns.loans, transaction.loan_id)

        socket
        |> assign(:loan, loan)
        |> assign(:page_title, "Edit Loan Transaction")
        |> assign(:transaction, transaction)

      {:error, %NotFoundError{}} ->
        put_flash(socket, :error, "Transaction is no longer present")
    end
  end

  defp apply_action(socket, _action, _params) do
    assign(socket, :page_title, "Transactions")
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <.account_bar
      account={@account}
      action={@live_action}
      balance={@account_balance}
      funds={@funds}
      return_path={@return_path}
      settings_path={~p"/transactions/account"}
    />
    <.account_tabs
      active={:transactions}
      funds_balance={@funds_balance}
      loans_balance={@loans_balance}
    />
    <.table id="account-transactions" row_id={&"txn-#{&1.id}"} rows={@transactions}>
      <:col :let={transaction} label="Type"><.icon name={type_icon(transaction)} /></:col>
      <:col :let={transaction} label="Date">{transaction.date}</:col>
      <:col :let={transaction} label="Memo">{transaction.memo}</:col>
      <:col :let={transaction} label="Fund/Loan">{transaction}</:col>
      <:col :let={transaction} align={:right} label="Out">
        <span :if={Money.negative?(transaction.amount)} data-role="out">
          {Money.negate!(transaction.amount)}
        </span>
      </:col>
      <:col :let={transaction} align={:right} label="In">
        <span :if={Money.positive?(transaction.amount)} data-role="in">
          {transaction.amount}
        </span>
      </:col>
      <:col :let={transaction} align={:right} label="Balance">
        {transaction.running_balance}
      </:col>
      <:action :let={transaction}>
        <.link patch={~p"/transactions/#{transaction}/edit?#{%{type: transaction.type}}"}>
          <.icon name="hero-pencil-square-micro" /> Edit
        </.link>
      </:action>
      <:action :let={transaction}>
        <.link
          data-confirm="Are you sure?"
          phx-click={
            JS.push("delete", value: %{id: transaction.id, type: transaction.type})
            |> hide("#txn-#{transaction.id}")
          }
        >
          <.icon name="hero-trash-micro" /> Delete
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

    <.modal
      :if={@live_action == :edit_transaction && match?(%Transaction{}, @transaction)}
      id="fund-transaction-modal"
      show
      on_cancel={JS.patch(@return_path)}
    >
      <.transaction_form
        account={@account}
        action={@live_action}
        all_funds={@funds}
        return_path={@return_path}
        transaction={@transaction}
      />
    </.modal>

    <.modal
      :if={@live_action == :edit_transaction && match?(%LoanTransaction{}, @transaction)}
      id="loan-transaction-modal"
      show
      on_cancel={JS.patch(@return_path)}
    >
      <.loan_transaction_form
        account={@account}
        action={@live_action}
        loan={@loan}
        return_path={@return_path}
        transaction={@transaction}
      />
    </.modal>
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

  defp find_loan(loans, loan_id) do
    Enum.find(loans, &(&1.id == loan_id))
  end

  defp load_transactions(socket) do
    %{account: account} = socket.assigns
    {transactions, %Paging{} = paging} = Transactions.list_account_transactions(account, per_page: @page_size)

    socket
    |> assign(:paging, paging)
    |> assign(:transactions, transactions)
  end
end
