defmodule FreedomAccountWeb.LoanLive.LoanForm do
  @moduledoc """
  For lending money from a Loan.
  """
  use FreedomAccountWeb, :live_view

  import FreedomAccountWeb.LoanTransactionForm, only: [loan_transaction_form: 1]

  alias Phoenix.LiveView

  on_mount FreedomAccountWeb.LoanLive.FetchLoan

  @impl LiveView
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Lend")
    |> ok()
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <.loan_transaction_form
      account={@account}
      action={:lend}
      loan={@loan}
      return_path={~p"/loans/#{@loan}"}
    />
    """
  end
end
