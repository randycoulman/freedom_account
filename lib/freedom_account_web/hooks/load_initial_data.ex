defmodule FreedomAccountWeb.Hooks.LoadInitialData do
  @moduledoc """
  Ensures that the account is available to all LiveViews using this hook.
  """
  import Phoenix.Component, only: [assign: 3, update: 3]

  alias FreedomAccount.Accounts
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.PubSub
  alias FreedomAccount.Transactions
  alias FreedomAccount.Transactions.Transaction
  alias FreedomAccountWeb.Hooks.LoadInitialData.FundCache
  alias Phoenix.LiveView
  alias Phoenix.LiveView.Socket

  @spec on_mount(atom(), map(), map(), Socket.t()) :: {:cont, Socket.t()}
  # on_mount signature is defined by LiveView and requires 4 args
  # credo:disable-for-next-line Credo.Check.Refactor.FunctionArity
  def on_mount(:default, _params, _session, socket) do
    if LiveView.connected?(socket) do
      PubSub.subscribe(Accounts.pubsub_topic())
      PubSub.subscribe(Funds.pubsub_topic())
      PubSub.subscribe(Transactions.pubsub_topic())
    end

    account = Accounts.only_account()
    funds = Funds.list_funds(account)

    {:cont,
     socket
     |> LiveView.attach_hook(:pubsub_events, :handle_info, &handle_info/2)
     |> assign(:account, account)
     |> assign(:funds, funds)}
  end

  defp handle_info({:account_updated, %Account{} = account}, socket) do
    {:cont, assign(socket, :account, account)}
  end

  defp handle_info({:budget_updated, funds}, socket) do
    {:cont, update_funds(socket, &FundCache.update_all(&1, funds))}
  end

  defp handle_info({:fund_created, %Fund{} = fund}, socket) do
    fund = %{fund | current_balance: Money.zero(:usd)}

    {:cont, update_funds(socket, &FundCache.add_fund(&1, fund))}
  end

  defp handle_info({:fund_deleted, %Fund{} = fund}, socket) do
    {:cont, update_funds(socket, &FundCache.delete_fund(&1, fund))}
  end

  defp handle_info({:fund_updated, %Fund{} = fund}, socket) do
    {:cont, update_funds(socket, &FundCache.update_fund(&1, fund))}
  end

  defp handle_info({:transaction_created, %Transaction{} = transaction}, socket) do
    %{account: account} = socket.assigns
    ids = Enum.map(transaction.line_items, & &1.fund_id)
    updated_funds = Funds.list_funds(account, ids)

    {:cont, update_funds(socket, &FundCache.update_all(&1, updated_funds))}
  end

  defp handle_info(_message, socket), do: {:cont, socket}

  defp update_funds(socket, fun) do
    socket = update(socket, :funds, fun)
    send(self(), {:funds_updated, socket.assigns.funds})
    socket
  end
end
