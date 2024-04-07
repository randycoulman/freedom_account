defmodule FreedomAccountWeb.HomeLive.Show do
  @moduledoc false

  use FreedomAccountWeb, :live_view

  alias FreedomAccount.Accounts
  alias Phoenix.LiveView

  @impl LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :account, Accounts.only_account())}
  end

  @impl LiveView
  def handle_params(params, _uri, socket) do
    {:noreply, assign(socket, fund_id: params["fund_id"], page_title: page_title(socket.assigns.live_action))}
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <.live_component
      account={@account}
      action={@live_action}
      id={@account.id}
      module={FreedomAccountWeb.AccountLive.Show}
      title={@page_title}
    />
    <.live_component
      account={@account}
      action={@live_action}
      fund_id={@fund_id}
      id={@account.id}
      module={FreedomAccountWeb.FundLive.Index}
      title={@page_title}
    />
    """
  end

  defp page_title(:show), do: "Freedom Account"
  defp page_title(:edit), do: "Edit Account Settings"
  defp page_title(:new_fund), do: "Add Fund"
  defp page_title(:edit_fund), do: "Edit Fund"
end
