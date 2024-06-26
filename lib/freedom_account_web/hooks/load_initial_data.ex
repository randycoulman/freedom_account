defmodule FreedomAccountWeb.Hooks.LoadInitialData do
  @moduledoc """
  Ensures that the account is available to all LiveViews using this hook.
  """

  alias FreedomAccount.Accounts
  alias FreedomAccount.Funds
  alias FreedomAccount.PubSub
  alias Phoenix.Component
  alias Phoenix.LiveView
  alias Phoenix.LiveView.Socket

  @spec on_mount(atom(), map(), map(), Socket.t()) :: {:cont, Socket.t()}
  # on_mount signature is defined by LiveView and requires 4 args
  # credo:disable-for-next-line Credo.Check.Refactor.FunctionArity
  def on_mount(:default, _params, _session, socket) do
    if LiveView.connected?(socket) do
      PubSub.subscribe(Accounts.pubsub_topic())
    end

    account = Accounts.only_account()

    {:cont,
     socket
     |> LiveView.attach_hook(:pubsub_events, :handle_info, &handle_info/2)
     |> Component.assign(:account, account)
     |> LiveView.stream(:funds, Funds.list_funds_with_balances(account))}
  end

  defp handle_info({:account_updated, account}, socket) do
    {:halt, Component.assign(socket, :account, account)}
  end

  defp handle_info(_message, socket), do: {:cont, socket}
end
