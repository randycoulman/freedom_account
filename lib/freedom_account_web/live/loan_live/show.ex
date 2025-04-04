defmodule FreedomAccountWeb.LoanLive.Show do
  @moduledoc false
  use FreedomAccountWeb, :live_view

  import FreedomAccountWeb.Account, only: [account: 1]
  import FreedomAccountWeb.LoanLive.Form, only: [settings_form: 1]
  import FreedomAccountWeb.LoanTransaction.Index, only: [loan_transaction_list: 1]
  import FreedomAccountWeb.LoanTransactionForm, only: [loan_transaction_form: 1]
  import FreedomAccountWeb.Sidebar, only: [sidebar: 1]

  alias FreedomAccount.Error
  alias FreedomAccount.Error.NotFoundError
  alias FreedomAccount.Loans.Loan
  alias FreedomAccount.Transactions
  alias FreedomAccount.Transactions.LoanTransaction
  alias FreedomAccountWeb.LoanTransaction.Index, as: TransactionList
  alias Phoenix.HTML.Safe
  alias Phoenix.LiveView

  @impl LiveView
  def handle_params(params, _url, socket) do
    id = String.to_integer(params["id"])
    %{loans: loans, live_action: action} = socket.assigns

    case fetch_loan(loans, id) do
      {:ok, %Loan{} = loan} ->
        socket
        |> assign(:loan, loan)
        |> assign(:transaction, nil)
        |> apply_action(action, params)
        |> noreply()

      {:error, %NotFoundError{}} ->
        socket
        |> put_flash(:error, "Loan not found")
        |> push_navigate(to: ~p"/loans")
        |> noreply()
    end
  end

  defp apply_action(socket, :edit, _params) do
    assign(socket, :page_title, "Edit Loan")
  end

  defp apply_action(socket, :edit_transaction, params) do
    transaction_id = String.to_integer(params["transaction_id"])

    case Transactions.fetch_loan_transaction(transaction_id) do
      {:ok, %LoanTransaction{} = transaction} ->
        socket
        |> assign(:page_title, "Edit Loan Transaction")
        |> assign(:transaction, transaction)

      {:error, %NotFoundError{}} ->
        put_flash(socket, :error, "Transaction is no longer present")
    end
  end

  defp apply_action(socket, :lend, _params) do
    socket
    |> assign(:page_title, "Lend")
    |> assign(:transaction, %LoanTransaction{})
  end

  defp apply_action(socket, :payment, _params) do
    socket
    |> assign(:page_title, "Payment")
    |> assign(:transaction, %LoanTransaction{})
  end

  defp apply_action(socket, _action, _params) do
    %{loan: loan} = socket.assigns

    assign(socket, :page_title, Safe.to_iodata(loan))
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <.account account={@account} balance={@account_balance} />
    <div class="flex h-screen">
      <aside class="hidden md:flex flex-col w-56 bg-slate-100">
        <.sidebar
          funds={@funds}
          funds_balance={@funds_balance}
          loans={@loans}
          loans_balance={@loans_balance}
        />
      </aside>
      <main class="flex flex-col flex-1 overflow-y-auto pl-2">
        <.header>
          <div class="flex flex-row">
            <span>{@loan}</span>
            <span>{@loan.current_balance}</span>
          </div>
          <:actions>
            <.link patch={~p"/loans/#{@loan}/loans/new"} phx-click={JS.push_focus()}>
              <.button>
                <.icon name="hero-credit-card-mini" /> Lend
              </.button>
            </.link>
            <.link patch={~p"/loans/#{@loan}/payments/new"} phx-click={JS.push_focus()}>
              <.button>
                <.icon name="hero-banknotes-mini" /> Payment
              </.button>
            </.link>
            <.link patch={~p"/loans/#{@loan}/show/edit"} phx-click={JS.push_focus()}>
              <.button>
                <.icon name="hero-pencil-square-mini" /> Edit Details
              </.button>
            </.link>
          </:actions>
        </.header>
        <.loan_transaction_list id={@loan.id} loan={@loan} />

        <.back navigate={~p"/loans"}>Back to Loans</.back>
      </main>
    </div>

    <.modal :if={@live_action == :edit} id="loan-modal" show on_cancel={JS.patch(~p"/loans/#{@loan}")}>
      <.settings_form
        account={@account}
        action={@live_action}
        loan={@loan}
        return_path={~p"/loans/#{@loan}"}
        title={@page_title}
      />
    </.modal>

    <.modal
      :if={@live_action in [:edit_transaction, :lend, :payment]}
      id="loan-transaction-modal"
      show
      on_cancel={JS.patch(~p"/loans/#{@loan}")}
    >
      <.loan_transaction_form
        account={@account}
        action={@live_action}
        loan={@loan}
        return_path={~p"/loans/#{@loan}"}
        transaction={@transaction}
      />
    </.modal>
    """
  end

  @impl LiveView
  def handle_info({:loans_updated, loans}, socket) do
    %{loan: loan, live_action: action} = socket.assigns

    case fetch_loan(loans, loan.id) do
      {:ok, %Loan{} = loan} ->
        socket
        |> assign(:loan, loan)
        |> apply_action(action, %{})
        |> noreply()

      {:error, %NotFoundError{}} ->
        noreply(socket)
    end
  end

  def handle_info({:loan_transaction_updated, transaction}, socket) do
    %{loan: loan} = socket.assigns

    if transaction.loan_id == loan.id do
      send_update(TransactionList, id: loan.id, loan: loan)
    end

    noreply(socket)
  end

  def handle_info(_message, socket), do: noreply(socket)

  defp fetch_loan(loans, id) do
    with %Loan{} = loan <- Enum.find(loans, {:error, Error.not_found(details: %{id: id}, entity: Loan)}, &(&1.id == id)) do
      {:ok, loan}
    end
  end
end
