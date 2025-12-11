defmodule FreedomAccountWeb.TransactionLive.TransactionForm do
  @moduledoc """
  For editing a fund or loan transaction.
  """
  use FreedomAccountWeb, :live_view

  import FreedomAccountWeb.FundTransactionForm, only: [fund_transaction_form: 1]

  alias FreedomAccount.Error.NotFoundError
  alias FreedomAccount.Transactions
  alias FreedomAccount.Transactions.Transaction
  alias Phoenix.LiveView

  @impl LiveView
  def mount(params, _session, socket) do
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

  @impl LiveView
  def render(assigns) do
    ~H"""
    <.fund_transaction_form
      account={@account}
      action={:edit_transaction}
      all_funds={@funds}
      return_path={~p"/transactions"}
      transaction={@transaction}
    />
    """
  end
end
