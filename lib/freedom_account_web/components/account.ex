defmodule FreedomAccountWeb.Account do
  @moduledoc false
  use FreedomAccountWeb, :html
  use Phoenix.Component

  # credo:disable-for-this-file Credo.Check.Readability.Specs
  # Reason: All component functions take a map of assigns that is fully
  # specified and checked at compile time by `attr` and `slot`, and they all
  # return a HEEx template, so no spec is necessary here.

  attr :account, :map, required: true
  attr :balance, :map, required: true

  def account(assigns) do
    ~H"""
    <header class="flex items-center justify-between gap-6 py-4">
      <div class="flex-1 flex flex-col items-center">
        <h2 class="text-lg font-medium"><.link navigate={~p"/funds"}>{@account.name}</.link></h2>
        <div class="text-2xl font-semibold" data-testid="account-balance">
          <.money value={@balance} />
        </div>
      </div>
    </header>
    """
  end
end
