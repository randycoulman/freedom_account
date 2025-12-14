defmodule FreedomAccountWeb.TransactionLive.TransactionForm do
  @moduledoc """
  For editing a fund or loan transaction.
  """
  use FreedomAccountWeb, :live_view

  import FreedomAccountWeb.FundTransactionForm, only: [fund_transaction_form: 1]
  import FreedomAccountWeb.LoanTransactionForm, only: [loan_transaction_form: 1]

  alias FreedomAccount.Error.NotFoundError
  alias FreedomAccount.Transactions
  alias FreedomAccount.Transactions.LoanTransaction
  alias FreedomAccount.Transactions.Transaction
  alias Phoenix.LiveView

  @impl LiveView
  def mount(%{"type" => "fund"} = params, _session, socket) do
    transaction_id = String.to_integer(params["id"])

    case Transactions.fetch_transaction(transaction_id) do
      {:ok, %Transaction{} = transaction} ->
        socket
        |> assign(:page_title, "Edit Transaction")
        |> assign(:transaction, transaction)
        |> ok()

      {:error, %NotFoundError{}} ->
        socket
        |> put_flash(:error, "Transaction is no longer present")
        |> push_navigate(to: ~p"/transactions")
        |> ok()
    end
  end

  def mount(%{"type" => "loan"} = params, _session, socket) do
    transaction_id = String.to_integer(params["id"])

    case Transactions.fetch_loan_transaction(transaction_id) do
      {:ok, %LoanTransaction{} = transaction} ->
        loan = find_loan(socket.assigns.loans, transaction.loan_id)

        socket
        |> assign(:loan, loan)
        |> assign(:page_title, "Edit Loan Transaction")
        |> assign(:transaction, transaction)
        |> ok()

      {:error, %NotFoundError{}} ->
        socket
        |> put_flash(:error, "Transaction is no longer present")
        |> push_navigate(to: ~p"/transactions")
        |> ok()
    end
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.fund_transaction_form
        :if={is_struct(@transaction, Transaction)}
        account={@account}
        action={:edit_transaction}
        all_funds={@funds}
        page_title={@page_title}
        return_path={~p"/transactions"}
        transaction={@transaction}
      />
      <.loan_transaction_form
        :if={is_struct(@transaction, LoanTransaction)}
        account={@account}
        action={:edit_transaction}
        loan={@loan}
        page_title={@page_title}
        return_path={~p"/transactions"}
        transaction={@transaction}
      />
    </Layouts.app>
    """
  end

  defp find_loan(loans, loan_id) do
    Enum.find(loans, &(&1.id == loan_id))
  end
end
