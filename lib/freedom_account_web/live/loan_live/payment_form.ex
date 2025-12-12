defmodule FreedomAccountWeb.LoanLive.PaymentForm do
  @moduledoc """
  For receiving a payment on a Loan.
  """
  use FreedomAccountWeb, :live_view

  import FreedomAccountWeb.LoanTransactionForm, only: [loan_transaction_form: 1]

  alias FreedomAccount.Loans.Loan
  alias FreedomAccount.Transactions.LoanTransaction
  alias Phoenix.LiveView

  @impl LiveView
  def mount(params, _session, socket) do
    id = String.to_integer(params["id"])

    case Enum.find(socket.assigns.loans, :not_found, &(&1.id == id)) do
      %Loan{} = loan ->
        socket
        |> assign(:loan, loan)
        |> assign(:page_title, "Payment")
        |> ok()

      :not_found ->
        socket
        |> put_flash(:error, "Loan not found")
        |> push_navigate(to: ~p"/loans")
        |> ok()
    end
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <.loan_transaction_form
      account={@account}
      action={:payment}
      loan={@loan}
      return_path={~p"/loans/#{@loan}"}
      transaction={%LoanTransaction{}}
    />
    """
  end
end
