defmodule FreedomAccountWeb.Account.Show do
  @moduledoc false

  use FreedomAccountWeb, :live_component

  alias FreedomAccountWeb.Account.Form
  alias Phoenix.LiveComponent

  @impl LiveComponent
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @account.name %>
        <:actions>
          <.link patch={@edit_path} phx-click={JS.push_focus()}>
            <.button>
              <.icon name="hero-cog-8-tooth-mini" /> Settings
            </.button>
          </.link>
        </:actions>
      </.header>

      <.modal
        :if={@action == :edit_account}
        id="account-modal"
        show
        on_cancel={JS.patch(@return_path)}
      >
        <.live_component
          account={@account}
          action={@action}
          id={@account.id}
          module={Form}
          navigate={@return_path}
        />
      </.modal>
    </div>
    """
  end
end
