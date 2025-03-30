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
  attr :return_path, :string, required: true
  attr :settings_path, :string, required: true

  @spec account_bar(Socket.assigns()) :: LiveView.Rendered.t()
  def account_bar(assigns) do
    ~H"""
    <.live_component id={@account.id} module={__MODULE__} {assigns} />
    """
  end

  @impl LiveComponent
  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> ok()
  end

  @impl LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <header class="flex items-center justify-between gap-6 py-4">
        <div class="flex-1 flex flex-col items-center">
          <h2 class="text-lg font-medium"><.link navigate={~p"/funds"}>{@account.name}</.link></h2>
          <div class="text-2xl font-semibold" data-testid="account-balance">{@balance}</div>
        </div>
        <.link patch={@settings_path} phx-click={JS.push_focus()}>
          <.button aria-label="Settings">
            <.icon name="hero-cog-8-tooth-mini" /><span class="sr-only">Settings</span>
          </.button>
        </.link>
      </header>
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
