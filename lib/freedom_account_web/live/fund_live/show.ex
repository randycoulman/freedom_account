defmodule FreedomAccountWeb.FundLive.Show do
  @moduledoc false
  use FreedomAccountWeb, :live_view

  import FreedomAccountWeb.Account, only: [account: 1]
  import FreedomAccountWeb.FundList, only: [fund_list: 1]

  alias FreedomAccount.Error
  alias FreedomAccount.Error.NotFoundError
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.Transactions
  alias FreedomAccount.Transactions.Transaction
  alias FreedomAccountWeb.FundLive.Form
  alias FreedomAccountWeb.FundTransaction
  alias FreedomAccountWeb.TransactionForm
  alias Phoenix.HTML.Safe
  alias Phoenix.LiveView

  @impl LiveView
  def handle_params(params, _url, socket) do
    id = String.to_integer(params["id"])
    %{funds: funds, live_action: action} = socket.assigns

    case fetch_fund(funds, id) do
      {:ok, %Fund{} = fund} ->
        {:noreply,
         socket
         |> assign(:fund, fund)
         |> assign(:transaction, nil)
         |> apply_action(action, params)}

      {:error, %NotFoundError{}} ->
        {:noreply,
         socket
         |> put_flash(:error, "Fund not found")
         |> push_navigate(to: ~p"/funds")}
    end
  end

  defp apply_action(socket, :edit, _params) do
    assign(socket, :page_title, "Edit Fund")
  end

  defp apply_action(socket, :edit_transaction, params) do
    transaction_id = String.to_integer(params["transaction_id"])

    case Transactions.fetch_transaction(transaction_id) do
      {:ok, %Transaction{} = transaction} ->
        socket
        |> assign(:page_title, "Edit Transaction")
        |> assign(:transaction, transaction)

      {:error, %NotFoundError{}} ->
        put_flash(socket, :error, "Transaction is no longer present")
    end
  end

  defp apply_action(socket, :deposit, _params) do
    assign(socket, :page_title, "Deposit")
  end

  defp apply_action(socket, :withdrawal, _params) do
    assign(socket, :page_title, "Withdraw")
  end

  defp apply_action(socket, _action, _params) do
    %{fund: fund} = socket.assigns

    assign(socket, :page_title, Safe.to_iodata(fund))
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <.account account={@account} balance={@account_balance} />
    <div class="flex h-screen">
      <aside class="hidden md:flex flex-col w-56 bg-slate-100">
        <.fund_list funds={@funds} />
      </aside>
      <main class="flex flex-col flex-1 overflow-y-auto pl-2">
        <.header>
          <div class="flex flex-row">
            <span><%= @fund %></span>
            <span><%= @fund.current_balance %></span>
          </div>
          <:subtitle>
            <div class="flex flex-row" id="fund-subtitle">
              <span>Budget: <%= @fund.budget %></span>
              <span>(<%= @fund.times_per_year %> times/year)</span>
            </div>
          </:subtitle>
          <:actions>
            <.link patch={~p"/funds/#{@fund}/show/edit"} phx-click={JS.push_focus()}>
              <.button>
                <.icon name="hero-pencil-square-mini" /> Edit Details
              </.button>
            </.link>
            <.link
              id="single-fund-deposit"
              patch={~p"/funds/#{@fund}/deposits/new"}
              phx-click={JS.push_focus()}
            >
              <.button>
                <.icon name="hero-plus-circle-mini" /> Deposit
              </.button>
            </.link>
            <.link
              id="single-fund-withdrawal"
              patch={~p"/funds/#{@fund}/withdrawals/new"}
              phx-click={JS.push_focus()}
            >
              <.button>
                <.icon name="hero-minus-circle-mini" /> Withdraw
              </.button>
            </.link>
          </:actions>
        </.header>
        <.live_component fund={@fund} id={@fund.id} module={FundTransaction.Index} />

        <.back navigate={~p"/funds"}>Back to Funds</.back>
      </main>
    </div>

    <.modal :if={@live_action == :edit} id="fund-modal" show on_cancel={JS.patch(~p"/funds/#{@fund}")}>
      <.live_component
        account={@account}
        action={@live_action}
        fund={@fund}
        id={@fund.id}
        module={Form}
        return_path={~p"/funds/#{@fund}"}
        title={@page_title}
      />
    </.modal>

    <.modal
      :if={@live_action in [:deposit, :edit_transaction, :withdrawal]}
      id="transaction-modal"
      show
      on_cancel={JS.patch(~p"/funds/#{@fund}")}
    >
      <.live_component
        account={@account}
        action={@live_action}
        funds={[@fund]}
        id={(@transaction && @transaction.id) || :new}
        module={TransactionForm}
        return_path={~p"/funds/#{@fund}"}
        title={@page_title}
        transaction={@transaction}
      />
    </.modal>
    """
  end

  @impl LiveView
  def handle_info({:funds_updated, funds}, socket) do
    %{fund: fund, live_action: action} = socket.assigns

    case fetch_fund(funds, fund.id) do
      {:ok, %Fund{} = fund} ->
        {:noreply,
         socket
         |> assign(:fund, fund)
         |> apply_action(action, %{})}

      {:error, %NotFoundError{}} ->
        {:noreply, socket}
    end
  end

  def handle_info(_message, socket), do: {:noreply, socket}

  defp fetch_fund(funds, id) do
    with %Fund{} = fund <- Enum.find(funds, {:error, Error.not_found(details: %{id: id}, entity: Fund)}, &(&1.id == id)) do
      {:ok, fund}
    end
  end
end
