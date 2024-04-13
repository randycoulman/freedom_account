defmodule FreedomAccountWeb.Account.Show do
  @moduledoc false

  use FreedomAccountWeb, :live_component

  alias FreedomAccountWeb.Account.Form
  alias Phoenix.LiveComponent

  @impl LiveComponent
  def update(assigns, socket) do
    %{account: account, action: action, title: title} = assigns

    socket =
      socket
      |> assign(:account, account)
      |> assign(:live_action, action)
      |> assign(:title, title)

    {:ok, socket}
  end

  @impl LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @account.name %>
        <:actions>
          <.link patch={~p"/funds/account/edit"} phx-click={JS.push_focus()}>
            <.button>
              <.icon name="hero-cog-8-tooth-mini" /> Settings
            </.button>
          </.link>
        </:actions>
      </.header>

      <.modal :if={@live_action == :edit_account} id="account-modal" show on_cancel={JS.patch(~p"/")}>
        <.live_component
          account={@account}
          action={@live_action}
          id={@account.id}
          module={Form}
          navigate={~p"/funds"}
          title={@title}
        />
      </.modal>
    </div>
    """
  end
end
