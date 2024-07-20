defmodule FreedomAccountWeb.FundTransaction.Index do
  @moduledoc false
  use FreedomAccountWeb, :live_component

  import FreedomAccountWeb.CoreComponents

  alias FreedomAccount.MoneyUtils
  alias FreedomAccount.Transactions
  alias Phoenix.LiveComponent

  @per_page 50
  @keep_limit @per_page * 3

  @impl LiveComponent
  def update(assigns, socket) do
    %{fund: fund} = assigns
    transactions = Transactions.list_fund_transactions(fund, per_page: @per_page)

    {:ok,
     socket
     |> assign(assigns)
     |> stream(:transactions, transactions, limit: @keep_limit)}
  end

  @impl LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.table
        id="fund-transactions"
        row_id={fn {_id, txn} -> "txn-#{txn.id}" end}
        rows={@streams.transactions}
      >
        <:col :let={{_id, txn}} label="Date"><span><%= txn.date %></span></:col>
        <:col :let={{_id, txn}} label="Memo"><span><%= txn.memo %></span></:col>
        <:col :let={{_id, txn}} label="Out">
          <span :if={Money.negative?(txn.amount)} data-role="withdrawal">
            <%= MoneyUtils.negate(txn.amount) %>
          </span>
        </:col>
        <:col :let={{_id, txn}} label="In">
          <span :if={Money.positive?(txn.amount)} data-role="deposit"><%= txn.amount %></span>
        </:col>
        <:empty_state>
          <div id="no-transactions">
            This fund has no transactions yet.
          </div>
        </:empty_state>
      </.table>
    </div>
    """
  end
end
