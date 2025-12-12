defmodule FreedomAccountWeb.FundLive.WithdrawalForm do
  @moduledoc """
  For making a withdrawal from a single fund.
  """
  use FreedomAccountWeb, :live_view

  import FreedomAccountWeb.FundTransactionForm, only: [fund_transaction_form: 1]

  alias Phoenix.LiveView

  on_mount FreedomAccountWeb.FundLive.FetchFund

  @impl LiveView
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Withdraw")
    |> ok()
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <.fund_transaction_form
      account={@account}
      action={:withdrawal}
      all_funds={@funds}
      fund={@fund}
      return_path={~p"/funds/#{@fund}"}
    />
    """
  end
end
