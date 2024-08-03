defmodule FreedomAccountWeb.FundLive.Index do
  @moduledoc false
  use FreedomAccountWeb, :live_view

  import FreedomAccountWeb.AccountBar.Show, only: [account_bar: 1]
  import FreedomAccountWeb.FundLive.Form, only: [settings_form: 1]

  alias FreedomAccount.Error
  alias FreedomAccount.Error.NotFoundError
  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund
  alias Phoenix.LiveView

  @impl LiveView
  def handle_params(params, _url, socket) do
    %{live_action: action} = socket.assigns

    {:noreply,
     socket
     |> assign(:fund, nil)
     |> apply_action(action, params)}
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
    <.account_bar account={@account} balance={@account_balance} action={@live_action} funds={@funds} />
    <.header>
      Funds
      <:actions>
        <.link patch={~p"/funds/new"}>
          <.button>
            <.icon name="hero-plus-circle-mini" /> Add Fund
          </.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="funds"
      row_click={fn fund -> JS.navigate(~p"/funds/#{fund}") end}
      row_id={fn fund -> "funds-#{fund.id}" end}
      rows={@funds}
    >
      <:col :let={fund} align={:center} label="Icon"><%= fund.icon %></:col>
      <:col :let={fund} label="Name"><%= fund.name %></:col>
      <:col :let={fund} align={:right} label="Budget"><%= fund.budget %></:col>
      <:col :let={fund} align={:right} label="Times/Year"><%= fund.times_per_year %></:col>
      <:col :let={fund} align={:right} label="Current Balance"><%= fund.current_balance %></:col>
      <:action :let={fund}>
        <div class="sr-only">
          <.link navigate={~p"/funds/#{fund}"}>Show</.link>
        </div>
        <.link patch={~p"/funds/#{fund}/edit"}>
          <.icon name="hero-pencil-square-micro" /> Edit
        </.link>
      </:action>
      <:action :let={fund}>
        <.link
          phx-click={JS.push("delete", value: %{id: fund.id}) |> hide("##{fund.id}")}
          data-confirm="Are you sure?"
        >
          <.icon name="hero-trash-micro" /> Delete
        </.link>
      </:action>
      <:empty_state>
        <div id="no-funds">
          This account has no funds yet. Use the Add Fund button to add one.
        </div>
      </:empty_state>
    </.table>

    <.modal :if={@live_action in [:new, :edit]} id="fund-modal" show on_cancel={JS.patch(~p"/funds")}>
      <.settings_form
        account={@account}
        action={@live_action}
        fund={@fund}
        return_path={~p"/funds"}
        title={@page_title}
      />
    </.modal>
    """
  end

  @impl LiveView
  def handle_event("delete", %{"id" => id}, socket) do
    with {:ok, fund} <- fetch_fund(socket, id),
         :ok <- Funds.delete_fund(fund) do
      {:noreply, socket}
    else
      {:error, error} ->
        {:noreply, put_flash(socket, :error, Exception.message(error))}
    end
  end

  @impl LiveView
  def handle_info(_message, socket), do: {:noreply, socket}

  defp fetch_fund(socket, id) do
    %{funds: funds} = socket.assigns

    with %Fund{} = fund <- Enum.find(funds, {:error, Error.not_found(details: %{id: id}, entity: Fund)}, &(&1.id == id)) do
      {:ok, fund}
    end
  end
end
