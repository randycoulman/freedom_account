defmodule FreedomAccountWeb.LoanLive.TransactionForm do
  @moduledoc """
  For editing a fund or loan transaction.
  """
  use FreedomAccountWeb, :live_view

  import FreedomAccountWeb.LoanTransactionForm, only: [loan_transaction_form: 1]

  alias FreedomAccount.Error.NotFoundError
  alias FreedomAccount.Transactions
  alias FreedomAccount.Transactions.LoanTransaction
  alias Phoenix.LiveView

  @impl LiveView
  def mount(params, _session, socket) do
    id = String.to_integer(params["id"])
    transaction_id = String.to_integer(params["transaction_id"])
    loan = find_loan(socket.assigns.loans, id)

    case Transactions.fetch_loan_transaction(transaction_id) do
      {:ok, %LoanTransaction{} = transaction} ->
        socket
        |> assign(:loan, loan)
        |> assign(:page_title, "Edit Loan Transaction")
        |> assign(:transaction, transaction)
        |> ok()

      {:error, %NotFoundError{}} ->
        socket
        |> put_flash(:error, "Transaction is no longer present")
        |> push_navigate(to: ~p"/loans/#{loan}")
        |> ok()
    end
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <.loan_transaction_form
      account={@account}
      action={:edit_transaction}
      loan={@loan}
      return_path={~p"/loans/#{@loan}"}
      transaction={@transaction}
    />
    """
  end

  defp find_loan(loans, loan_id) do
    Enum.find(loans, &(&1.id == loan_id))
  end
end
