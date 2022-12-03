defmodule FreedomAccountWeb.FundLive.Index do
  use FreedomAccountWeb, :live_component

  alias FreedomAccount.Funds
  # alias FreedomAccount.Funds.Fund
  alias Phoenix.LiveComponent

  @impl LiveComponent
  def update(%{account: account}, socket) do
    # {:ok, assign(socket, :funds, Funds.list_funds(account))}
    {:ok, assign(socket, :funds, list_funds(account))}
  end

  # @impl LiveComponent
  # def handle_params(params, _url, socket) do
  #   {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  # end

  # defp apply_action(socket, :edit, %{"id" => id}) do
  #   socket
  #   |> assign(:page_title, "Edit Fund")
  #   |> assign(:fund, Funds.get_fund!(id))
  # end

  # defp apply_action(socket, :new, _params) do
  #   socket
  #   |> assign(:page_title, "New Fund")
  #   |> assign(:fund, %Fund{})
  # end

  # defp apply_action(socket, :index, _params) do
  #   socket
  #   |> assign(:page_title, "Listing Funds")
  #   |> assign(:fund, nil)
  # end

  # @impl LiveComponent
  # def handle_event("delete", %{"id" => id}, socket) do
  #   fund = Funds.get_fund!(id)
  #   {:ok, _} = Funds.delete_fund(fund)

  #   {:noreply, assign(socket, :funds, list_funds())}
  # end

  defp list_funds(account) do
    account
    |> Funds.list_funds()
    |> Enum.sort_by(& &1.name)
  end
end
