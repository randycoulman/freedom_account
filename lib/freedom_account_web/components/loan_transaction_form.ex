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
  attr :action, :atom, required: true
  attr :loan, Loan, required: true
  attr :page_title, :string, required: true
  attr :return_path, :string, required: true
  attr :transaction, LoanTransaction, default: nil

  @spec loan_transaction_form(Socket.assigns()) :: LiveView.Rendered.t()
  def loan_transaction_form(assigns) do
    ~H"""
    <.live_component
      id={if @transaction, do: @transaction.id, else: :new}
      module={__MODULE__}
      {assigns}
    />
    """
  end

  @impl LiveComponent
  def update(assigns, socket) do
    transaction = assigns.transaction || %LoanTransaction{}

    changeset =
      if is_nil(transaction.id) do
        Transactions.new_loan_transaction(assigns.loan)
      else
        Transactions.change_loan_transaction(transaction)
      end

    socket
    |> assign(assigns)
    |> assign(:form, to_form(changeset))
    |> assign(:transaction, transaction)
    |> apply_action(assigns.action)
    |> ok()
  end

  defp apply_action(socket, :edit_transaction) do
    assign(socket, :save, "Save Transaction")
  end

  defp apply_action(socket, :lend) do
    assign(socket, :save, "Lend Money")
  end

  defp apply_action(socket, :payment) do
    assign(socket, :save, "Receive Payment")
  end

  @impl LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.standard_form
        class="max-w-md"
        for={@form}
        id="loan-transaction-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        title={@page_title}
      >
        <:subtitle>
          <span data-role="loan">{@loan}</span>
        </:subtitle>
        <.input field={@form[:date]} label="Date" phx-debounce="blur" type="date" />
        <.input field={@form[:memo]} label="Memo" phx-debounce="blur" type="text" />
        <.input field={@form[:amount]} label="Amount" phx-debounce="blur" type="text" />
        <.input field={@form[:loan_id]} type="hidden" />
        <:actions>
          <.button phx-disable-with="Saving..." type="submit" variant="primary">
            <.icon name="hero-check-circle-mini" /> {@save}
          </.button>
          <.button navigate={@return_path}>Cancel</.button>
        </:actions>
      </.standard_form>
    </div>
    """
  end

  @impl LiveComponent
  def handle_event("validate", params, socket) do
    %{"loan_transaction" => transaction_params} = params
    changeset = Transactions.change_loan_transaction(socket.assigns.transaction, transaction_params)

    socket
    |> assign(:form, to_form(changeset, action: :validate))
    |> noreply()
  end

  def handle_event("save", params, socket) do
    %{"loan_transaction" => transaction_params} = params

    save_transaction(socket, socket.assigns.action, Params.atomize_keys(transaction_params))
  end

  defp save_transaction(socket, :edit_transaction, params) do
    case Transactions.update_loan_transaction(socket.assigns.transaction, params) do
      {:ok, _transaction} ->
        socket
        |> put_flash(:info, "Transaction updated successfully")
        |> push_navigate(to: socket.assigns.return_path)
        |> noreply()

      {:error, %Changeset{} = changeset} ->
        socket
        |> assign(:form, to_form(changeset))
        |> noreply()
    end
  end

  defp save_transaction(socket, :lend, params) do
    case Transactions.lend(socket.assigns.account, params) do
      {:ok, _transaction} ->
        socket
        |> put_flash(:info, "Money lent successfully")
        |> push_navigate(to: socket.assigns.return_path)
        |> noreply()

      {:error, %Changeset{} = changeset} ->
        socket
        |> assign(:form, to_form(changeset))
        |> noreply()
    end
  end

  defp save_transaction(socket, :payment, params) do
    case Transactions.receive_payment(socket.assigns.account, params) do
      {:ok, _transaction} ->
        socket
        |> put_flash(:info, "Payment successful")
        |> push_navigate(to: socket.assigns.return_path)
        |> noreply()

      {:error, %Changeset{} = changeset} ->
        socket
        |> assign(:form, to_form(changeset))
        |> noreply()
    end
  end
end
