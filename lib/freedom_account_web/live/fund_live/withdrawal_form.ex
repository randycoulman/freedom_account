defmodule FreedomAccountWeb.FundLive.WithdrawalForm do
  @moduledoc """
  For making a withdrawal from a single fund.
  """
  use FreedomAccountWeb, :live_view

  import FreedomAccountWeb.FundTransactionForm, only: [fund_transaction_form: 1]
  import FreedomAccountWeb.Sidebar, only: [sidebar: 1]

  alias Phoenix.LiveView

  on_mount FreedomAccountWeb.FundLive.FetchFund

  @impl LiveView
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Withdraw")
    |> ok()
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="flex">
        <aside class="hidden md:flex flex-col w-56">
          <.sidebar
            funds={@funds}
            funds_balance={@funds_balance}
            loans={@loans}
            loans_balance={@loans_balance}
          />
        </aside>
        <main class="flex-1 pl-2">
          <.fund_transaction_form
            account={@account}
            action={:withdrawal}
            all_funds={@funds}
            fund={@fund}
            page_title={@page_title}
            return_path={~p"/funds/#{@fund}"}
          />
        </main>
      </div>
    </Layouts.app>
    """
  end
end
