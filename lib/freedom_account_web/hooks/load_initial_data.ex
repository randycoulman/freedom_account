defmodule FreedomAccountWeb.Hooks.LoadInitialData do
  @moduledoc """
  Ensures that the account is available to all LiveViews using this hook.
  """

  import Phoenix.Component, only: [assign: 2]

  alias FreedomAccount.Accounts
  alias FreedomAccount.Funds
  alias Phoenix.LiveView
  alias Phoenix.LiveView.Socket

  @spec on_mount(atom(), map(), map(), Socket.t()) :: {:cont, Socket.t()}
  # on_mount signature is defined by LiveView and requires 4 args
  # credo:disable-for-next-line Credo.Check.Refactor.FunctionArity
  def on_mount(:default, _params, _session, socket) do
    account = Accounts.only_account()

    {:cont,
     socket
     |> assign(account: account)
     |> LiveView.stream(:funds, Funds.list_funds_with_balances(account))}
  end
end
