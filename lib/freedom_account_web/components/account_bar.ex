defmodule FreedomAccountWeb.AccountBar do
  @moduledoc false

  use FreedomAccountWeb, :live_component

  alias FreedomAccount.Accounts.Account
  alias Phoenix.LiveComponent
  alias Phoenix.LiveView
  alias Phoenix.LiveView.Socket

  attr :account, Account, required: true
  attr :balance, Money, required: true
  attr :return_to, :string, required: true

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
    <header class="flex items-center justify-between gap-6 py-4">
      <div class="flex-1 flex flex-col items-center">
        <h2 class="text-lg font-medium"><.link navigate={~p"/funds"}>{@account.name}</.link></h2>
        <div class="text-2xl font-semibold" data-testid="account-balance">{@balance}</div>
      </div>
      <.button
        aria-label="Settings"
        navigate={~p"/account/edit?return_to=#{@return_to}"}
      >
        <.icon name="hero-cog-8-tooth-mini" /><span class="sr-only">Settings</span>
      </.button>
    </header>
    """
  end
end
