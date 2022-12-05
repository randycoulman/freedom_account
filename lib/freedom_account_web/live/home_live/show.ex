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
  def handle_params(_params, _uri, socket) do
    {:noreply, assign(socket, :page_title, page_title(socket.assigns.live_action))}
  end

  defp page_title(:show), do: "Freedom Account"
  defp page_title(:edit), do: "Edit Account Settings"
  defp page_title(:new_fund), do: "Add Fund"
end
