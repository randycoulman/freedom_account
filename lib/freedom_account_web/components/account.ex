defmodule FreedomAccountWeb.Account do
  @moduledoc false
  use FreedomAccountWeb, :verified_routes
  use Phoenix.Component

  import FreedomAccountWeb.CoreComponents

  # credo:disable-for-this-file Credo.Check.Readability.Specs
  # Reason: All component functions take a map of assigns that is fully
  # specified and checked at compile time by `attr` and `slot`, and they all
  # return a HEEx template, so no spec is necessary here.

  attr :account, :map, required: true
  attr :balance, :map, required: true

  def account(assigns) do
    ~H"""
    <.header>
      <.link navigate={~p"/funds"}><%= @account.name %></.link>
      <span><%= @balance %></span>
    </.header>
    """
  end
end
