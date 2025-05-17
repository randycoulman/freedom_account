defmodule FreedomAccountWeb.FundLive.Index do
  @moduledoc false
  use FreedomAccountWeb, :live_view

  import FreedomAccountWeb.AccountBar.Show, only: [account_bar: 1]
  import FreedomAccountWeb.AccountTabs, only: [account_tabs: 1]
  import FreedomAccountWeb.BudgetForm, only: [budget_form: 1]
  import FreedomAccountWeb.FundActivationForm, only: [fund_activation_form: 1]
  import FreedomAccountWeb.FundCard, only: [fund_card: 1]
  import FreedomAccountWeb.FundLive.Form, only: [settings_form: 1]
  import FreedomAccountWeb.RegularDepositForm, only: [regular_deposit_form: 1]
  import FreedomAccountWeb.TransactionForm, only: [transaction_form: 1]

  alias FreedomAccount.Error
  alias FreedomAccount.Error.NotFoundError
  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.Transactions.Transaction
  alias Phoenix.LiveView

  @impl LiveView
  def handle_params(params, _url, socket) do
    %{live_action: action} = socket.assigns

    socket
    |> assign(:fund, nil)
    |> assign(:return_path, ~p"/funds")
    |> apply_action(action, params)
    |> noreply()
  end

  defp apply_action(socket, :activate, _params) do
    assign(socket, :page_title, "Activate/Deactivate")
  end

  defp apply_action(socket, :edit, params) do
    id = String.to_integer(params["id"])

    case fetch_fund(socket, id) do
      {:ok, %Fund{} = fund} ->
        socket
        |> assign(:page_title, "Edit Fund")
        |> assign(:fund, fund)

      {:error, %NotFoundError{}} ->
        put_flash(socket, :error, "Fund is no longer present")
    end
  end

  defp apply_action(socket, :edit_account, _params) do
    assign(socket, :page_title, "Edit Account Settings")
  end

  defp apply_action(socket, :edit_budget, _params) do
    assign(socket, :page_title, "Update Budget")
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Add Fund")
    |> assign(:fund, %Fund{})
  end

  defp apply_action(socket, :regular_deposit, _params) do
    assign(socket, :page_title, "Regular Deposit")
  end

  defp apply_action(socket, :regular_withdrawal, _params) do
    assign(socket, :page_title, "Regular Withdrawal")
  end

  defp apply_action(socket, _action, _params) do
    socket
    |> assign(:page_title, "Funds")
    |> assign(:fund, nil)
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <.account_bar
      account={@account}
      action={@live_action}
      balance={@account_balance}
      funds={@funds}
      return_path={@return_path}
      settings_path={~p"/funds/account"}
    />
    <.account_tabs active={:funds} funds_balance={@funds_balance} loans_balance={@loans_balance} />
    <div class="flex flex-row gap-2 justify-end py-4">
      <.link patch={~p"/funds/regular_deposit"} phx-click={JS.push_focus()}>
        <.button>
          <.icon name="hero-folder-plus-mini" /> Regular Deposit
        </.button>
      </.link>
      <.link patch={~p"/funds/regular_withdrawal"} phx-click={JS.push_focus()}>
        <.button>
          <.icon name="hero-folder-minus-mini" /> Regular Withdrawal
        </.button>
      </.link>
      <.link patch={~p"/funds/budget"} phx-click={JS.push_focus()}>
        <.button>
          <.icon name="hero-chart-pie-mini" /> Budget
        </.button>
      </.link>
      <.link patch={~p"/funds/activate"} phx-click={JS.push_focus()}>
        <.button>
          <.icon name="hero-archive-box-mini" /> Activate/Deactivate
        </.button>
      </.link>
      <.link patch={~p"/funds/new"}>
        <.button>
          <.icon name="hero-plus-circle-mini" /> Add Fund
        </.button>
      </.link>
    </div>

    <div class="flex flex-col">
      <div :if={@funds == []} class="mx-auto p-4" id="no-funds">
        This account has no funds yet. Use the Add Fund button to add one.
      </div>
      <.fund_card
        :for={fund <- @funds}
        class="hover:cursor-pointer"
        id={"funds-#{fund.id}"}
        fund={fund}
        phx-click={JS.navigate(~p"/funds/#{fund}")}
      />
    </div>

    <.modal
      :if={@live_action == :activate}
      id="activate-modal"
      show
      on_cancel={JS.patch(@return_path)}
    >
      <.fund_activation_form account={@account} return_path={@return_path} />
    </.modal>

    <.modal :if={@live_action in [:edit, :new]} id="fund-modal" show on_cancel={JS.patch(~p"/funds")}>
      <.settings_form
        account={@account}
        action={@live_action}
        fund={@fund}
        return_path={~p"/funds"}
        title={@page_title}
      />
    </.modal>

    <.modal
      :if={@live_action == :edit_budget}
      id="budget-modal"
      show
      on_cancel={JS.patch(@return_path)}
    >
      <.budget_form account={@account} funds={@funds} return_path={@return_path} />
    </.modal>

    <.modal
      :if={@live_action == :regular_deposit}
      id="regular-deposit-modal"
      show
      on_cancel={JS.patch(@return_path)}
    >
      <.regular_deposit_form account={@account} funds={@funds} return_path={@return_path} />
    </.modal>

    <.modal
      :if={@live_action == :regular_withdrawal}
      id="regular-withdrawal-modal"
      show
      on_cancel={JS.patch(@return_path)}
    >
      <.transaction_form
        account={@account}
        action={@live_action}
        all_funds={@funds}
        initial_funds={@funds}
        return_path={@return_path}
        transaction={%Transaction{}}
      />
    </.modal>
    """
  end

  @impl LiveView
  def handle_event("delete", %{"id" => id}, socket) do
    with {:ok, fund} <- fetch_fund(socket, id),
         :ok <- Funds.delete_fund(fund) do
      noreply(socket)
    else
      {:error, error} ->
        socket
        |> put_flash(:error, Exception.message(error))
        |> noreply()
    end
  end

  defp fetch_fund(socket, id) do
    %{funds: funds} = socket.assigns

    with %Fund{} = fund <- Enum.find(funds, {:error, Error.not_found(details: %{id: id}, entity: Fund)}, &(&1.id == id)) do
      {:ok, fund}
    end
  end
end
