defmodule FreedomAccountWeb.FundLive.Show do
  @moduledoc false
  use FreedomAccountWeb, :live_view

  import FreedomAccountWeb.FundList, only: [fund_list: 1]

  alias FreedomAccount.Funds
  alias FreedomAccount.Transactions
  alias FreedomAccountWeb.DepositForm
  alias FreedomAccountWeb.FundLive.Form
  alias Phoenix.HTML.Safe
  alias Phoenix.LiveView

  @impl LiveView
  def handle_params(%{"id" => id} = params, _url, socket) do
    %{account: account, live_action: action} = socket.assigns

    case Funds.fetch_fund_with_balance(account, id) do
      {:ok, fund} ->
        {:noreply,
         socket
         |> assign(:fund, fund)
         |> apply_action(action, params)}

      {:error, :not_found} ->
        {:noreply,
         socket
         |> put_flash(:error, "Fund not found")
         |> push_navigate(to: ~p"/funds")}
    end
  end

  defp apply_action(socket, :edit, _params) do
    assign(socket, :page_title, "Edit Fund")
  end

  defp apply_action(socket, :edit_account, _params) do
    assign(socket, :page_title, "Edit Account Settings")
  end

  defp apply_action(socket, :new_deposit, _params) do
    socket
    |> assign(:page_title, "Deposit")
    |> assign(:deposit, Transactions.new_deposit(socket.assigns.fund))
  end

  defp apply_action(socket, _action, _params) do
    %{fund: fund} = socket.assigns

    assign(socket, :page_title, Safe.to_iodata(fund))
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <.live_component
      account={@account}
      action={@live_action}
      edit_path={~p"/funds/#{@fund}/account"}
      id={@account.id}
      module={FreedomAccountWeb.Account.Show}
      return_path={~p"/funds/#{@fund}"}
    />
    <div class="flex h-screen">
      <aside class="hidden md:flex flex-col w-56 bg-slate-100">
        <.fund_list funds={@streams.funds} />
      </aside>
      <main class="flex flex-col flex-1 overflow-y-auto pl-2">
        <.header>
          <div class="flex flex-row">
            <span><%= @fund %></span>
            <span><%= @fund.current_balance %></span>
          </div>
          <:actions>
            <.link patch={~p"/funds/#{@fund}/show/edit"} phx-click={JS.push_focus()}>
              <.button>
                <.icon name="hero-pencil-square-mini" /> Edit Details
              </.button>
            </.link>
            <.link patch={~p"/funds/#{@fund}/deposits/new"} phx-click={JS.push_focus()}>
              <.button>
                <.icon name="hero-plus-circle-mini" /> Deposit
              </.button>
            </.link>
          </:actions>
        </.header>

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
        patch={~p"/funds/#{@fund}"}
        title={@page_title}
      />
    </.modal>

    <.modal
      :if={@live_action == :new_deposit}
      id="deposit-modal"
      show
      on_cancel={JS.patch(~p"/funds/#{@fund}")}
    >
      <.live_component
        action={@live_action}
        deposit={@deposit}
        fund={@fund}
        id={@deposit.id || :new}
        module={DepositForm}
        patch={~p"/funds/#{@fund}"}
        title={@page_title}
      />
    </.modal>
    """
  end

  @impl LiveView
  def handle_info({Form, {:saved, fund}}, socket) do
    {:noreply, stream_insert(socket, :funds, fund)}
  end

  def handle_info({DepositForm, {:balance_updated, fund}}, socket) do
    case Funds.with_updated_balance(fund) do
      {:ok, fund} ->
        {:noreply, stream_insert(socket, :funds, fund)}

      {:error, _error} ->
        {:noreply, put_flash(socket, :error, "Unable to retrieve updated balance for #{fund}")}
    end
  end
end
