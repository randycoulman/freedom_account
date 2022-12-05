defmodule FreedomAccountWeb.AccountLive.Show do
  @moduledoc false

  use FreedomAccountWeb, :live_component

  alias Phoenix.LiveComponent

  @impl LiveComponent
  def update(%{account: account, action: action, title: title}, socket) do
    socket =
      socket
      |> assign(:account, account)
      |> assign(:live_action, action)
      |> assign(:page_title, title)

    {:ok, socket}
  end
end
