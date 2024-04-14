defmodule FreedomAccountWeb.FundLive.Index do
  @moduledoc false
  use FreedomAccountWeb, :live_view

  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund
  alias FreedomAccountWeb.FundLive.Form
  alias Phoenix.LiveView

  @impl LiveView
  def mount(_params, _session, socket) do
    %{account: account} = socket.assigns
    {:ok, stream(socket, :funds, list_funds(account))}
  end

  @impl LiveView
  def handle_params(params, _url, socket) do
    %{live_action: action} = socket.assigns
    {:noreply, apply_action(socket, action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(page_title: "Add Fund")
    |> assign(:fund, %Fund{})
  end

  defp apply_action(socket, :edit, %{"id" => id} = _params) do
    %{account: account} = socket.assigns

    case Funds.fetch_fund(account, id) do
      {:ok, %Fund{} = fund} ->
        socket
        |> assign(page_title: "Edit Fund")
        |> assign(:fund, fund)

      {:error, :not_found} ->
        put_flash(socket, :error, "Fund is no longer present")
    end
  end

  defp apply_action(socket, :edit_account, _params) do
    socket
    |> assign(page_title: "Edit Account Settings")
    |> assign(fund: nil)
  end

  defp apply_action(socket, _action, _params) do
    socket
    |> assign(page_title: "Funds")
    |> assign(:fund, nil)
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <.live_component
      account={@account}
      action={@live_action}
      edit_path={~p"/funds/account"}
      id={@account.id}
      module={FreedomAccountWeb.Account.Show}
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
      row_click={fn {_id, fund} -> JS.navigate(~p"/funds/#{fund}") end}
      row_id={fn {_id, fund} -> "funds-#{fund.id}" end}
      rows={@streams.funds}
    >
      <:col :let={{_id, fund}} label="Icon"><%= fund.icon %></:col>
      <:col :let={{_id, fund}} label="Name"><%= fund.name %></:col>
      <:action :let={{_id, fund}}>
        <div class="sr-only">
          <.link navigate={~p"/funds/#{fund}"}>Show</.link>
        </div>
        <.link patch={~p"/funds/#{fund}/edit"}>
          <.icon name="hero-pencil-square-mini" /> Edit
        </.link>
      </:action>
      <:action :let={{id, fund}}>
        <.link
          phx-click={JS.push("delete", value: %{id: fund.id}) |> hide("##{id}")}
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
        patch={~p"/funds"}
        title={@page_title}
      />
    </.modal>
    """
  end

  @impl LiveView
  def handle_event("delete", %{"id" => id}, socket) do
    %{account: account} = socket.assigns

    with {:ok, fund} <- Funds.fetch_fund(account, id),
         :ok <- Funds.delete_fund(fund) do
      {:noreply, stream_delete(socket, :funds, fund)}
    else
      {:error, error} ->
        {:noreply, put_flash(socket, :error, "Unable to delete fund: #{error}")}
    end
  end

  @impl LiveView
  def handle_info({Form, {:saved, fund}}, socket) do
    {:noreply, stream_insert(socket, :funds, fund)}
  end

  defp list_funds(account) do
    account
    |> Funds.list_funds()
    |> Enum.sort_by(& &1.name)
  end
end
