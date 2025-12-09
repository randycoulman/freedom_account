defmodule FreedomAccountWeb.FundLive.DepositForm do
  @moduledoc """
  For making a deposit to a single fund.
  """
  use FreedomAccountWeb, :live_view

  import FreedomAccountWeb.FundTransactionForm, only: [fund_transaction_form: 1]

  alias FreedomAccount.Transactions.Transaction
  alias Phoenix.LiveView

  on_mount FreedomAccountWeb.FundLive.FetchFund

  @impl LiveView
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Deposit")
    |> ok()
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <.fund_transaction_form
      account={@account}
      action={:deposit}
      all_funds={@funds}
      initial_funds={[@fund]}
      return_path={~p"/funds/#{@fund}"}
      transaction={%Transaction{}}
    />
    """
  end
end
