defmodule FreedomAccountWeb.AccountBar.Show do
  @moduledoc false

  use FreedomAccountWeb, :live_component

  import FreedomAccountWeb.AccountBar.Form, only: [settings_form: 1]

  alias FreedomAccount.Accounts.Account
  alias Phoenix.LiveComponent
  alias Phoenix.LiveView
  alias Phoenix.LiveView.Socket

  attr :account, Account, required: true
  attr :action, :string, required: true
  attr :balance, Money, required: true
  attr :funds, :list, required: true

  @spec account_bar(Socket.assigns()) :: LiveView.Rendered.t()
  def account_bar(assigns) do
    ~H"""
    <.live_component id={@account.id} module={__MODULE__} {assigns} />
    """
  end

  @impl LiveComponent
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:return_path, ~p"/funds")}
  end

  @impl LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <.link navigate={~p"/funds"}><%= @account.name %></.link>
        <span><%= @balance %></span>
        <:actions>
          <.link patch={~p"/funds/account"} phx-click={JS.push_focus()}>
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
        <.settings_form account={@account} funds={@funds} return_path={@return_path} />
      </.modal>
    </div>
    """
  end
end
