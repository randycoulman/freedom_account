defmodule FreedomAccountWeb.FundLive.Show do
  @moduledoc false
  use FreedomAccountWeb, :live_view

  import FreedomAccountWeb.FundList, only: [fund_list: 1]

  alias FreedomAccount.Funds.Fund
  alias FreedomAccountWeb.FundLive.Form
  alias FreedomAccountWeb.TransactionForm
  alias Phoenix.HTML.Safe
  alias Phoenix.LiveView

  @impl LiveView
  def handle_params(params, _url, socket) do
    id = String.to_integer(params["id"])
    %{live_action: action} = socket.assigns

    case fetch_fund(socket, id) do
      {:ok, %Fund{} = fund} ->
        {:noreply,
         socket
         |> assign(:fund, fund)
         |> apply_action(action)}

      {:error, :not_found} ->
        {:noreply,
         socket
         |> put_flash(:error, "Fund not found")
         |> push_navigate(to: ~p"/funds")}
    end
  end

  defp apply_action(socket, :edit) do
    assign(socket, :page_title, "Edit Fund")
  end

  defp apply_action(socket, :edit_account) do
    assign(socket, :page_title, "Edit Account Settings")
  end

  defp apply_action(socket, :edit_budget) do
    assign(socket, :page_title, "Update Budget")
  end

  defp apply_action(socket, :deposit) do
    assign(socket, :page_title, "Deposit")
  end

  defp apply_action(socket, :regular_deposit) do
    assign(socket, :page_title, "Regular Deposit")
  end

  defp apply_action(socket, :regular_withdrawal) do
    assign(socket, :page_title, "Regular Withdrawal")
  end

  defp apply_action(socket, :withdrawal) do
    assign(socket, :page_title, "Withdraw")
  end

  defp apply_action(socket, _action) do
    %{fund: fund} = socket.assigns

    assign(socket, :page_title, Safe.to_iodata(fund))
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <.live_component
      account={@account}
      action={@live_action}
      budget_path={~p"/funds/#{@fund}/budget"}
      edit_path={~p"/funds/#{@fund}/account"}
      funds={@funds}
      id={@account.id}
      module={FreedomAccountWeb.Account.Show}
      regular_deposit_path={~p"/funds/#{@fund}/regular_deposit"}
      regular_withdrawal_path={~p"/funds/#{@fund}/regular_withdrawal"}
      return_path={~p"/funds/#{@fund}"}
    />
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
      :if={@live_action in [:deposit, :withdrawal]}
      id="transaction-modal"
      show
      on_cancel={JS.patch(~p"/funds/#{@fund}")}
    >
      <.live_component
        action={@live_action}
        funds={[@fund]}
        id={:new}
        module={TransactionForm}
        return_path={~p"/funds/#{@fund}"}
        title={@page_title}
      />
    </.modal>
    """
  end

  @impl LiveView
  def handle_info({:funds_updated, _funds}, socket) do
    %{fund: fund, live_action: action} = socket.assigns

    case fetch_fund(socket, fund.id) do
      {:ok, %Fund{} = fund} ->
        {:noreply,
         socket
         |> assign(:fund, fund)
         |> apply_action(action)}

      {:error, :not_found} ->
        {:noreply, socket}
    end
  end

  def handle_info(_message, socket), do: {:noreply, socket}

  defp fetch_fund(socket, id) do
    %{funds: funds} = socket.assigns

    with %Fund{} = fund <- Enum.find(funds, {:error, :not_found}, &(&1.id == id)) do
      {:ok, fund}
    end
  end
end
