defmodule FreedomAccountWeb.FundLive.Index do
  @moduledoc false
  use FreedomAccountWeb, :live_view

  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund
  alias FreedomAccountWeb.FundLive.Form
  alias Phoenix.LiveView

  @impl LiveView
  def handle_params(params, _url, socket) do
    %{live_action: action} = socket.assigns
    {:noreply, apply_action(socket, action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Add Fund")
    |> assign(:fund, %Fund{})
  end

  defp apply_action(socket, :edit, params) do
    id = String.to_integer(params["id"])

    case fetch_fund(socket, id) do
      {:ok, %Fund{} = fund} ->
        socket
        |> assign(:page_title, "Edit Fund")
        |> assign(:fund, fund)

      {:error, :not_found} ->
        put_flash(socket, :error, "Fund is no longer present")
    end
  end

  defp apply_action(socket, :edit_account, _params) do
    socket
    |> assign(:page_title, "Edit Account Settings")
    |> assign(:fund, nil)
  end

  defp apply_action(socket, :edit_budget, _params) do
    socket
    |> assign(:page_title, "Update Budget")
    |> assign(fund: nil)
  end

  defp apply_action(socket, :regular_deposit, _params) do
    socket
    |> assign(:page_title, "Regular Deposit")
    |> assign(:fund, nil)
  end

  defp apply_action(socket, _action, _params) do
    socket
    |> assign(:page_title, "Funds")
    |> assign(:fund, nil)
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <.live_component
      account={@account}
      action={@live_action}
      budget_path={~p"/funds/budget"}
      edit_path={~p"/funds/account"}
      funds={@funds}
      id={@account.id}
      module={FreedomAccountWeb.Account.Show}
      regular_deposit_path={~p"/funds/regular_deposit"}
      return_path={~p"/funds"}
    />
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
      <:col :let={fund} label="Icon"><%= fund.icon %></:col>
      <:col :let={fund} label="Name"><%= fund.name %></:col>
      <:col :let={fund} label="Budget"><%= fund.budget %></:col>
      <:col :let={fund} label="Times/Year"><%= fund.times_per_year %></:col>
      <:col :let={fund} label="Current Balance"><%= fund.current_balance %></:col>
      <:action :let={fund}>
        <div class="sr-only">
          <.link navigate={~p"/funds/#{fund}"}>Show</.link>
        </div>
        <.link patch={~p"/funds/#{fund}/edit"}>
          <.icon name="hero-pencil-square-mini" /> Edit
        </.link>
      </:action>
      <:action :let={fund}>
        <.link
          phx-click={JS.push("delete", value: %{id: fund.id}) |> hide("##{fund.id}")}
          data-confirm="Are you sure?"
        >
          <.icon name="hero-trash-mini" /> Delete
        </.link>
      </:action>
      <:empty_state>
        <div id="no-funds">
          This account has no funds yet. Use the Add Fund button to add one.
        </div>
      </:empty_state>
    </.table>

    <.modal :if={@live_action in [:new, :edit]} id="fund-modal" show on_cancel={JS.patch(~p"/funds")}>
      <.live_component
        account={@account}
        action={@live_action}
        fund={@fund}
        id={@fund.id || :new}
        module={Form}
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
        {:noreply, put_flash(socket, :error, "Unable to delete fund: #{error}")}
    end
  end

  @impl LiveView
  def handle_info(_message, socket), do: {:noreply, socket}

  defp fetch_fund(socket, id) do
    %{funds: funds} = socket.assigns

    with %Fund{} = fund <- Enum.find(funds, {:error, :not_found}, &(&1.id == id)) do
      {:ok, fund}
    end
  end
end
