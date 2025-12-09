defmodule FreedomAccountWeb.FundLive.WithdrawalForm do
  @moduledoc """
  For making a withdrawal from a single fund.
  """
  use FreedomAccountWeb, :live_view

  import FreedomAccountWeb.FundTransactionForm, only: [fund_transaction_form: 1]

  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.Transactions.Transaction
  alias Phoenix.LiveView

  @impl LiveView
  def mount(params, _session, socket) do
    id = String.to_integer(params["id"])

    case Enum.find(socket.assigns.funds, :not_found, &(&1.id == id)) do
      %Fund{} = fund ->
        socket
        |> assign(:page_title, "Withdraw")
        |> assign(:fund, fund)
        |> ok()

      :not_found ->
        socket
        |> put_flash(:error, "Fund not found")
        |> push_navigate(~p"/funds")
        |> noreply()
    end
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <.fund_transaction_form
      account={@account}
      action={:withdrawal}
      all_funds={@funds}
      initial_funds={[@fund]}
      return_path={~p"/funds/#{@fund}"}
      transaction={%Transaction{}}
    />
    """
  end
end
