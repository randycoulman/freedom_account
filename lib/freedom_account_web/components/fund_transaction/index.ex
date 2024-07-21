defmodule FreedomAccountWeb.FundTransaction.Index do
  @moduledoc false
  use FreedomAccountWeb, :live_component

  import FreedomAccountWeb.CoreComponents

  alias FreedomAccount.MoneyUtils
  alias FreedomAccount.Paging
  alias FreedomAccount.Transactions
  alias Phoenix.LiveComponent

  @page_size 10

  @doc false
  @spec page_size :: pos_integer()
  def page_size, do: @page_size

  @impl LiveComponent
  def update(assigns, socket) do
    %{fund: fund} = assigns
    {transactions, %Paging{} = paging} = Transactions.list_fund_transactions(fund, per_page: @page_size)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:paging, paging)
     |> assign(:transactions, transactions)
     |> stream(:transactions, transactions, reset: true)}
  end

  @impl LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.table id="fund-transactions" row_id={&"txn-#{&1.id}"} rows={@transactions}>
        <:col :let={txn} label="Date"><%= txn.date %></:col>
        <:col :let={txn} label="Memo"><%= txn.memo %></:col>
        <:col :let={txn} align={:right} label="Out">
          <span :if={Money.negative?(txn.amount)} data-role="withdrawal">
            <%= MoneyUtils.negate(txn.amount) %>
          </span>
        </:col>
        <:col :let={txn} align={:right} label="In">
          <span :if={Money.positive?(txn.amount)} data-role="deposit"><%= txn.amount %></span>
        </:col>
        <:col :let={txn} align={:right} label="Balance">
          <%= txn.running_balance %>
        </:col>
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
  def handle_event("next-page", _params, socket) do
    %{fund: fund, paging: paging} = socket.assigns

    {transactions, %Paging{} = next_paging} =
      Transactions.list_fund_transactions(fund, next_cursor: paging.next_cursor, per_page: @page_size)

    {:noreply,
     socket
     |> assign(:paging, next_paging)
     |> assign(:transactions, transactions)}
  end

  @impl LiveComponent
  def handle_event("prev-page", _params, socket) do
    %{fund: fund, paging: paging} = socket.assigns

    {transactions, %Paging{} = next_paging} =
      Transactions.list_fund_transactions(fund, prev_cursor: paging.prev_cursor, per_page: @page_size)

    {:noreply,
     socket
     |> assign(:paging, next_paging)
     |> assign(:transactions, transactions)}
  end
end
