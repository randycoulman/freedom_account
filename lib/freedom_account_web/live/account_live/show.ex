defmodule FreedomAccountWeb.AccountLive.Show do
  @moduledoc false

  use FreedomAccountWeb, :live_view

  alias FreedomAccount.Accounts
  alias Phoenix.LiveView

  @impl LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl LiveView
  def handle_params(_params, _uri, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:account, Accounts.only_account())}
  end

  defp page_title(:show), do: "Freedom Account"
  defp page_title(:edit), do: "Edit Account Settings"
  defp page_title(:new_fund), do: "Add Fund"
end
