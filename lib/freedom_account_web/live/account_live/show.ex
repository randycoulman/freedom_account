defmodule FreedomAccountWeb.AccountLive.Show do
  @moduledoc false

  use FreedomAccountWeb, :live_component

  alias FreedomAccountWeb.AccountLive.Form
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

  @impl LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @account.name %>
        <:actions>
          <.link patch={~p"/edit"} phx-click={JS.push_focus()}>
            <.button>Edit</.button>
          </.link>
        </:actions>
      </.header>

      <.modal :if={@live_action == :edit} id="account-modal" show on_cancel={JS.patch(~p"/")}>
        <.live_component
          account={@account}
          action={@live_action}
          id={@account.id}
          module={Form}
          navigate={~p"/"}
          title={@page_title}
        />
      </.modal>
    </div>
    """
  end
end
