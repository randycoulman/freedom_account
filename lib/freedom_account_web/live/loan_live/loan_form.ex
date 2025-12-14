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
    <Layouts.app flash={@flash}>
      <.loan_transaction_form
        account={@account}
        action={:lend}
        loan={@loan}
        page_title={@page_title}
        return_path={~p"/loans/#{@loan}"}
      />
    </Layouts.app>
    """
  end
end
