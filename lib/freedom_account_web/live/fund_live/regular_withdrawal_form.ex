defmodule FreedomAccountWeb.FundLive.RegularWithdrawalForm do
  @moduledoc """
  For making a regular withdrawal transaction.
  """
  use FreedomAccountWeb, :live_view

  import FreedomAccountWeb.FundTransactionForm, only: [fund_transaction_form: 1]

  alias Phoenix.LiveView

  @impl LiveView
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Regular Withdrawal")
    |> ok()
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <.fund_transaction_form
      account={@account}
      action={:regular_withdrawal}
      all_funds={@funds}
      return_path={~p"/funds"}
    />
    """
  end
end
