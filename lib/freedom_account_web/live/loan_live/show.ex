defmodule FreedomAccountWeb.LoanLive.Show do
  @moduledoc false
  use FreedomAccountWeb, :live_view

  import FreedomAccountWeb.Account, only: [account: 1]
  import FreedomAccountWeb.LoanTransactionList, only: [loan_transaction_list: 1]
  import FreedomAccountWeb.Sidebar, only: [sidebar: 1]

  alias FreedomAccount.Error
  alias FreedomAccount.Error.NotFoundError
  alias FreedomAccount.Loans.Loan
  alias FreedomAccountWeb.Layouts
  alias FreedomAccountWeb.LoanTransactionList
  alias Phoenix.HTML.Safe
  alias Phoenix.LiveView

  on_mount FreedomAccountWeb.LoanLive.FetchLoan

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
        <aside class="hidden md:flex flex-col mr-2 w-56">
          <.sidebar
            funds={@funds}
            funds_balance={@funds_balance}
            loans={@loans}
            loans_balance={@loans_balance}
          />
        </aside>
        <main class="flex flex-col flex-1 overflow-y-auto">
          <.header class="bg-primary/15 px-4 py-2">
            <div class="flex flex-row items-center justify-between">
              <span>{@loan}</span>
              <.money value={@loan.current_balance} />
            </div>
            <:actions>
              <.button class="btn btn-outline btn-primary" navigate={~p"/loans"}>
                <.icon name="hero-arrow-left" />
                <span class="sr-only">Back to Loans</span>
              </.button>
              <.button class="btn btn-outline btn-primary" navigate={~p"/loans/#{@loan}/loans/new"}>
                <.icon name="hero-credit-card-mini" /> Lend
              </.button>
              <.button class="btn btn-outline btn-primary" navigate={~p"/loans/#{@loan}/payments/new"}>
                <.icon name="hero-banknotes-mini" /> Payment
              </.button>
              <.button
                class="btn btn-outline btn-primary"
                navigate={~p"/loans/#{@loan}/edit?return_to=show"}
              >
                <.icon name="hero-pencil-square-mini" /> <span class="sr-only">Edit Details</span>
              </.button>
            </:actions>
          </.header>
          <.loan_transaction_list id={@loan.id} loan={@loan} />
        </main>
      </div>
    </Layouts.app>
    """
  end

  @impl LiveView
  def handle_info({:loans_updated, loans}, socket) do
    %{loan: loan} = socket.assigns

    case fetch_loan(loans, loan.id) do
      {:ok, %Loan{} = loan} ->
        socket
        |> assign(:loan, loan)
        |> assign_page_title()
        |> noreply()

      {:error, %NotFoundError{}} ->
        noreply(socket)
    end
  end

  def handle_info({:loan_transaction_updated, transaction}, socket) do
    %{loan: loan} = socket.assigns

    if transaction.loan_id == loan.id do
      send_update(LoanTransactionList, id: loan.id, loan: loan)
    end

    noreply(socket)
  end

  def handle_info(_message, socket), do: noreply(socket)

  defp assign_page_title(socket) do
    assign(socket, :page_title, Safe.to_iodata(socket.assigns.loan))
  end

  defp fetch_loan(loans, id) do
    with %Loan{} = loan <- Enum.find(loans, {:error, Error.not_found(details: %{id: id}, entity: Loan)}, &(&1.id == id)) do
      {:ok, loan}
    end
  end
end
