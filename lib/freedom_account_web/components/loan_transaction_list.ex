defmodule FreedomAccountWeb.LoanTransactionList do
  @moduledoc false
  use FreedomAccountWeb, :live_component

  import FreedomAccountWeb.CoreComponents

  alias FreedomAccount.Loans.Loan
  alias FreedomAccount.Paging
  alias FreedomAccount.Transactions
  alias Phoenix.LiveComponent
  alias Phoenix.LiveView
  alias Phoenix.LiveView.Socket

  @page_size 10

  attr :id, :integer, required: true
  attr :loan, Loan, required: true

  @spec loan_transaction_list(Socket.assigns()) :: LiveView.Rendered.t()
  def loan_transaction_list(assigns) do
    ~H"""
    <.live_component module={__MODULE__} {assigns} />
    """
  end

  @doc false
  @spec page_size :: pos_integer()
  def page_size, do: @page_size

  @impl LiveComponent
  def update(assigns, socket) do
    %{loan: loan} = assigns
    {transactions, %Paging{} = paging} = Transactions.list_loan_transactions(loan, per_page: @page_size)

    socket
    |> assign(assigns)
    |> assign(:paging, paging)
    |> assign(:transactions, transactions)
    |> ok()
  end

  @impl LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.table
        id="loan-transactions"
        row_click={&JS.navigate(~p"/loans/#{@loan}/transactions/#{&1}/edit")}
        row_id={&"txn-#{&1.id}"}
        rows={@transactions}
      >
        <:col :let={transaction} label="Date">{transaction.date}</:col>
        <:col :let={transaction} label="Memo">{transaction.memo}</:col>
        <:col :let={transaction} align={:right} label="Out">
          <span :if={Money.negative?(transaction.amount)} data-role="loan">
            {Money.negate!(transaction.amount)}
          </span>
        </:col>
        <:col :let={transaction} align={:right} label="In">
          <span :if={Money.positive?(transaction.amount)} data-role="payment">
            {transaction.amount}
          </span>
        </:col>
        <:col :let={transaction} align={:right} label="Balance">
          {transaction.running_balance}
        </:col>
        <:action :let={transaction}>
          <.link
            class="link link-hover"
            data-confirm="Are you sure?"
            phx-click={
              JS.push("delete", value: %{id: transaction.id}) |> hide("#txn-#{transaction.id}")
            }
            phx-target={@myself}
          >
            <.icon name="hero-trash-micro" /> <span class="sr-only">Delete</span>
          </.link>
        </:action>
        <:empty_state>
          <div id="no-transactions">
            This loan has no transactions yet.
          </div>
        </:empty_state>
      </.table>
      <.button
        disabled={is_nil(@paging.prev_cursor)}
        phx-click="prev-page"
        phx-disable-with="Loading..."
        phx-target={@myself}
        type="button"
      >
        <.icon name="hero-arrow-left-circle-mini" /> Previous Page
      </.button>
      <.button
        disabled={is_nil(@paging.next_cursor)}
        phx-click="next-page"
        phx-disable-with="Loading..."
        phx-target={@myself}
        type="button"
      >
        Next Page <.icon name="hero-arrow-right-circle-mini" />
      </.button>
    </div>
    """
  end

  @impl LiveComponent
  def handle_event("delete", %{"id" => id}, socket) do
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
    %{loan: loan, paging: paging} = socket.assigns

    {transactions, %Paging{} = next_paging} =
      Transactions.list_loan_transactions(loan, next_cursor: paging.next_cursor, per_page: @page_size)

    socket
    |> assign(:paging, next_paging)
    |> assign(:transactions, transactions)
    |> noreply()
  end

  @impl LiveComponent
  def handle_event("prev-page", _params, socket) do
    %{loan: loan, paging: paging} = socket.assigns

    {transactions, %Paging{} = next_paging} =
      Transactions.list_loan_transactions(loan, prev_cursor: paging.prev_cursor, per_page: @page_size)

    socket
    |> assign(:paging, next_paging)
    |> assign(:transactions, transactions)
    |> noreply()
  end
end
