defmodule FreedomAccountWeb.FundTransaction.Index do
  @moduledoc false
  use FreedomAccountWeb, :live_component

  import FreedomAccountWeb.CoreComponents

  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.Paging
  alias FreedomAccount.Transactions
  alias Phoenix.LiveComponent
  alias Phoenix.LiveView
  alias Phoenix.LiveView.Socket

  @page_size 10

  attr :id, :integer, required: true
  attr :fund, Fund, required: true

  @spec fund_transaction_list(Socket.assigns()) :: LiveView.Rendered.t()
  def fund_transaction_list(assigns) do
    ~H"""
    <.live_component module={__MODULE__} {assigns} />
    """
  end

  @doc false
  @spec page_size :: pos_integer()
  def page_size, do: @page_size

  @impl LiveComponent
  def update(assigns, socket) do
    %{fund: fund} = assigns
    {transactions, %Paging{} = paging} = Transactions.list_fund_transactions(fund, per_page: @page_size)

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
      <.table id="fund-transactions" row_id={&"txn-#{&1.line_item_id}"} rows={@transactions}>
        <:col :let={transaction} label="Date">{transaction.date}</:col>
        <:col :let={transaction} label="Memo">{transaction.memo}</:col>
        <:col :let={transaction} align={:right} label="Out">
          <span :if={Money.negative?(transaction.amount)} data-role="withdrawal">
            {Money.negate!(transaction.amount)}
          </span>
        </:col>
        <:col :let={transaction} align={:right} label="In">
          <span :if={Money.positive?(transaction.amount)} data-role="deposit">
            {transaction.amount}
          </span>
        </:col>
        <:col :let={transaction} align={:right} label="Balance">
          {transaction.running_balance}
        </:col>
        <:action :let={transaction}>
          <.link patch={~p"/funds/#{@fund}/transactions/#{transaction}/edit"}>
            <.icon name="hero-pencil-square-micro" /> Edit
          </.link>
        </:action>
        <:action :let={transaction}>
          <.link
            data-confirm="Are you sure?"
            phx-click={
              JS.push("delete", value: %{id: transaction.id})
              |> hide("#txn-#{transaction.line_item_id}")
            }
            phx-target={@myself}
          >
            <.icon name="hero-trash-micro" /> Delete
          </.link>
        </:action>
        <:empty_state>
          <div id="no-transactions">
            This fund has no transactions yet.
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

  def handle_event("next-page", _params, socket) do
    %{fund: fund, paging: paging} = socket.assigns

    {transactions, %Paging{} = next_paging} =
      Transactions.list_fund_transactions(fund, next_cursor: paging.next_cursor, per_page: @page_size)

    socket
    |> assign(:paging, next_paging)
    |> assign(:transactions, transactions)
    |> noreply()
  end

  def handle_event("prev-page", _params, socket) do
    %{fund: fund, paging: paging} = socket.assigns

    {transactions, %Paging{} = next_paging} =
      Transactions.list_fund_transactions(fund, prev_cursor: paging.prev_cursor, per_page: @page_size)

    socket
    |> assign(:paging, next_paging)
    |> assign(:transactions, transactions)
    |> noreply()
  end
end
