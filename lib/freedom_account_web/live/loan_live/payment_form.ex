defmodule FreedomAccountWeb.LoanLive.PaymentForm do
  @moduledoc """
  For receiving a payment on a Loan.
  """
  use FreedomAccountWeb, :live_view

  import FreedomAccountWeb.LoanTransactionForm, only: [loan_transaction_form: 1]

  alias Phoenix.LiveView

  on_mount FreedomAccountWeb.LoanLive.FetchLoan

  @impl LiveView
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Payment")
    |> ok()
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <.loan_transaction_form
      account={@account}
      action={:payment}
      loan={@loan}
      return_path={~p"/loans/#{@loan}"}
    />
    """
  end
end
