defmodule FreedomAccountWeb.FundLive.Show do
  @moduledoc false
  use FreedomAccountWeb, :live_view

  import FreedomAccountWeb.Account, only: [account: 1]
  import FreedomAccountWeb.FundTransactionList, only: [fund_transaction_list: 1]
  import FreedomAccountWeb.Sidebar, only: [sidebar: 1]

  alias FreedomAccount.Error
  alias FreedomAccount.Error.NotFoundError
  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund
  alias FreedomAccountWeb.FundTransactionList
  alias FreedomAccountWeb.Layouts
  alias Phoenix.HTML.Safe
  alias Phoenix.LiveView

  on_mount FreedomAccountWeb.FundLive.FetchFund

  @impl LiveView
  def handle_params(_params, _url, socket) do
    socket
    |> assign_page_title()
    |> noreply()
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.account account={@account} balance={@account_balance} />
      <div class="flex h-screen">
        <aside class="hidden md:flex flex-col w-56">
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
              <span>{@fund}</span>
              <span>{@fund.current_balance}</span>
            </div>
            <:subtitle>
              <div class="flex flex-row" id="fund-subtitle">
                <span>
                  Deposit: {Funds.regular_deposit_amount(@fund, @account)} ({@fund.budget} @ {@fund.times_per_year} times/year)
                </span>
              </div>
            </:subtitle>
            <:actions>
              <.button navigate={~p"/funds"}>
                <.icon name="hero-arrow-left" />
                <span class="sr-only">Back to Funds</span>
              </.button>
              <.button navigate={~p"/funds/#{@fund}/deposits/new"}>
                <.icon name="hero-plus-circle-mini" /> Deposit
              </.button>
              <.button navigate={~p"/funds/#{@fund}/withdrawals/new"}>
                <.icon name="hero-minus-circle-mini" /> Withdraw
              </.button>
              <.button navigate={~p"/funds/#{@fund}/edit?return_to=show"}>
                <.icon name="hero-pencil-square-mini" /> Edit Details
              </.button>
            </:actions>
          </.header>
          <.fund_transaction_list fund={@fund} id={@fund.id} />
        </main>
      </div>
    </Layouts.app>
    """
  end

  @impl LiveView
  def handle_info({:funds_updated, funds}, socket) do
    %{fund: fund} = socket.assigns

    case fetch_fund(funds, fund.id) do
      {:ok, %Fund{} = fund} ->
        socket
        |> assign(:fund, fund)
        |> assign_page_title()
        |> noreply()

      {:error, %NotFoundError{}} ->
        noreply(socket)
    end
  end

  def handle_info({:transaction_updated, transaction}, socket) do
    %{fund: fund} = socket.assigns

    if Enum.any?(transaction.line_items, &(&1.fund_id == fund.id)) do
      send_update(FundTransactionList, id: fund.id, fund: fund)
    end

    noreply(socket)
  end

  def handle_info(_message, socket), do: noreply(socket)

  defp assign_page_title(socket) do
    assign(socket, :page_title, Safe.to_iodata(socket.assigns.fund))
  end

  defp fetch_fund(funds, id) do
    with %Fund{} = fund <- Enum.find(funds, {:error, Error.not_found(details: %{id: id}, entity: Fund)}, &(&1.id == id)) do
      {:ok, fund}
    end
  end
end
