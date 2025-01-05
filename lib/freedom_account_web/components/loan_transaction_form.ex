defmodule FreedomAccountWeb.LoanTransactionForm do
  @moduledoc """
  For making a transaction for a loan.
  """
  use FreedomAccountWeb, :live_component

  alias Ecto.Changeset
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Loans.Loan
  alias FreedomAccount.Transactions
  alias FreedomAccount.Transactions.LoanTransaction
  alias FreedomAccountWeb.Params
  alias Phoenix.LiveComponent
  alias Phoenix.LiveView
  alias Phoenix.LiveView.Socket

  attr :account, Account, required: true
  attr :action, :string, required: true
  attr :loan, Loan, required: true
  attr :return_path, :string, required: true
  attr :transaction, LoanTransaction, required: true

  @spec loan_transaction_form(Socket.assigns()) :: LiveView.Rendered.t()
  def loan_transaction_form(assigns) do
    ~H"""
    <.live_component id={@transaction.id || :new} module={__MODULE__} {assigns} />
    """
  end

  @impl LiveComponent
  def update(assigns, socket) do
    %{action: action, loan: loan, transaction: transaction} = assigns

    changeset =
      if is_nil(transaction.id) do
        Transactions.new_loan_transaction(loan)
      else
        Transactions.change_loan_transaction(transaction)
      end

    socket
    |> assign(assigns)
    |> apply_action(action)
    |> assign_form(changeset)
    |> ok()
  end

  defp apply_action(socket, :edit_transaction) do
    socket
    |> assign(:heading, "Edit Loan Transaction")
    |> assign(:save, "Save Transaction")
  end

  defp apply_action(socket, :lend) do
    socket
    |> assign(:heading, "Lend")
    |> assign(:save, "Lend Money")
  end

  defp apply_action(socket, :payment) do
    socket
    |> assign(:heading, "Payment")
    |> assign(:save, "Receive Payment")
  end

  @impl LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@heading}
        <:subtitle>
          <span data-role="loan">{@loan}</span>
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="loan-transaction-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:date]} label="Date" phx-debounce="blur" type="date" />
        <.input field={@form[:memo]} label="Memo" phx-debounce="blur" type="text" />
        <.input field={@form[:amount]} label="Amount" phx-debounce="blur" type="text" />
        <.input field={@form[:loan_id]} type="hidden" />
        <:actions>
          <.button phx-disable-with="Saving..." type="submit">
            <.icon name="hero-check-circle-mini" /> {@save}
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl LiveComponent
  def handle_event("validate", params, socket) do
    %{"loan_transaction" => transaction_params} = params

    transaction = socket.assigns[:transaction] || %LoanTransaction{}

    changeset =
      transaction
      |> Transactions.change_loan_transaction(transaction_params)
      |> Map.put(:action, :validate)

    socket
    |> assign_form(changeset)
    |> noreply()
  end

  def handle_event("save", params, socket) do
    %{"loan_transaction" => transaction_params} = params
    %{action: action} = socket.assigns

    save_transaction(socket, action, Params.atomize_keys(transaction_params))
  end

  defp save_transaction(socket, :edit_transaction, params) do
    %{return_path: return_path, transaction: transaction} = socket.assigns

    case Transactions.update_loan_transaction(transaction, params) do
      {:ok, _transaction} ->
        socket
        |> put_flash(:info, "Transaction updated successfully")
        |> push_patch(to: return_path)
        |> noreply()

      {:error, %Changeset{} = changeset} ->
        socket
        |> assign_form(changeset)
        |> noreply()
    end
  end

  defp save_transaction(socket, :lend, params) do
    %{account: account, return_path: return_path} = socket.assigns

    case Transactions.lend(account, params) do
      {:ok, _transaction} ->
        socket
        |> put_flash(:info, "Money lent successfully")
        |> push_patch(to: return_path)
        |> noreply()

      {:error, %Changeset{} = changeset} ->
        socket
        |> assign_form(changeset)
        |> noreply()
    end
  end

  defp save_transaction(socket, :payment, params) do
    %{account: account, return_path: return_path} = socket.assigns

    case Transactions.receive_payment(account, params) do
      {:ok, _transaction} ->
        socket
        |> put_flash(:info, "Payment successful")
        |> push_patch(to: return_path)
        |> noreply()

      {:error, %Changeset{} = changeset} ->
        socket
        |> assign_form(changeset)
        |> noreply()
    end
  end

  defp assign_form(socket, %Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
