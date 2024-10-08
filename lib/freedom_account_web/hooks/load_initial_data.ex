defmodule FreedomAccountWeb.Hooks.LoadInitialData do
  @moduledoc """
  Ensures that the account is available to all LiveViews using this hook.
  """
  import FreedomAccountWeb.SocketHelpers
  import Phoenix.Component, only: [assign: 3, update: 3]
  import Phoenix.LiveView, only: [attach_hook: 4, connected?: 1, put_flash: 3]

  alias FreedomAccount.Accounts
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Balances
  alias FreedomAccount.Error.ServiceError
  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.Loans
  alias FreedomAccount.Loans.Loan
  alias FreedomAccount.PubSub
  alias FreedomAccount.Transactions
  alias FreedomAccount.Transactions.LoanTransaction
  alias FreedomAccount.Transactions.Transaction
  alias FreedomAccountWeb.Hooks.LoadInitialData.Cache
  alias Phoenix.LiveView.Socket

  @spec on_mount(atom(), map(), map(), Socket.t()) :: {:cont, Socket.t()}
  def on_mount(:default, _params, _session, socket) do
    socket =
      if connected?(socket) do
        subscribe_to_topics(socket)
      else
        socket
      end

    account = Accounts.only_account()
    funds = Funds.list_active_funds(account)
    loans = Loans.list_active_loans(account)

    socket
    |> attach_hook(:pubsub_events, :handle_info, &handle_info/2)
    |> assign(:account, account)
    |> assign_balances()
    |> assign(:funds, funds)
    |> assign(:loans, loans)
    |> cont()
  end

  defp subscribe_to_topics(socket) do
    with :ok <- PubSub.subscribe(Accounts.pubsub_topic()),
         :ok <- PubSub.subscribe(Funds.pubsub_topic()),
         :ok <- PubSub.subscribe(Loans.pubsub_topic()),
         :ok <- PubSub.subscribe(Transactions.pubsub_topic()) do
      socket
    else
      {:error, %ServiceError{} = error} ->
        message = """
        #{Exception.message(error)}

        Refresh your browser tab to try again.

        If you continue to see this error, the application is still usable.
        However, some screens may not update correctly when making changes.
        Please refresh your browser tab after making changes.
        """

        put_flash(socket, :warning, message)
    end
  end

  defp handle_info({:account_updated, %Account{} = account}, socket) do
    socket
    |> assign(:account, account)
    |> cont()
  end

  defp handle_info({:budget_updated, funds}, socket) do
    socket
    |> update_funds(&Cache.update_all(&1, funds))
    |> cont()
  end

  defp handle_info({:fund_activation_updated, funds}, socket) do
    socket
    |> update_funds(&Cache.update_activations(&1, funds))
    |> cont()
  end

  defp handle_info({:fund_created, %Fund{} = fund}, socket) do
    fund = %{fund | current_balance: Money.zero(:usd)}

    socket
    |> update_funds(&Cache.add(&1, fund))
    |> cont()
  end

  defp handle_info({:fund_deleted, %Fund{} = fund}, socket) do
    socket
    |> update_funds(&Cache.delete(&1, fund))
    |> cont()
  end

  defp handle_info({:fund_updated, %Fund{} = fund}, socket) do
    socket
    |> update_funds(&Cache.update(&1, fund))
    |> cont()
  end

  defp handle_info({:loan_activation_updated, loans}, socket) do
    socket
    |> update_loans(&Cache.update_activations(&1, loans))
    |> cont()
  end

  defp handle_info({:loan_created, %Loan{} = loan}, socket) do
    loan = %{loan | current_balance: Money.zero(:usd)}

    socket
    |> update_loans(&Cache.add(&1, loan))
    |> cont()
  end

  defp handle_info({:loan_deleted, %Loan{} = loan}, socket) do
    socket
    |> update_loans(&Cache.delete(&1, loan))
    |> cont()
  end

  defp handle_info({:loan_updated, %Loan{} = loan}, socket) do
    socket
    |> update_loans(&Cache.update(&1, loan))
    |> cont()
  end

  defp handle_info({event, %LoanTransaction{} = transaction}, socket)
       when event in [:loan_transaction_created, :loan_transaction_deleted, :loan_transaction_updated] do
    %{account: account} = socket.assigns
    {:ok, loan} = Loans.fetch_active_loan(account, transaction.loan_id)
    {:ok, loan} = Loans.with_updated_balance(loan)

    socket
    |> assign_balances()
    |> update_loans(&Cache.update(&1, loan))
    |> cont()
  end

  defp handle_info({event, %Transaction{} = transaction}, socket)
       when event in [:transaction_created, :transaction_deleted, :transaction_updated] do
    %{account: account} = socket.assigns
    ids = Enum.map(transaction.line_items, & &1.fund_id)
    updated_funds = Funds.list_active_funds(account, ids)

    socket
    |> assign_balances()
    |> update_funds(&Cache.update_all(&1, updated_funds))
    |> cont()
  end

  defp handle_info(_message, socket), do: cont(socket)

  defp assign_balances(socket) do
    %{account: account} = socket.assigns
    summary = Balances.summary(account)

    socket
    |> assign(:account_balance, summary.total)
    |> assign(:funds_balance, summary.funds)
    |> assign(:loans_balance, summary.loans)
  end

  defp update_funds(socket, fun) do
    socket = update(socket, :funds, fun)
    send(self(), {:funds_updated, socket.assigns.funds})
    socket
  end

  defp update_loans(socket, fun) do
    socket = update(socket, :loans, fun)
    send(self(), {:loans_updated, socket.assigns.loans})
    socket
  end
end
