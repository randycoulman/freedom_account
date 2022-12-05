defmodule FreedomAccountWeb.FundLive.Index do
  use FreedomAccountWeb, :live_component

  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund
  alias Phoenix.LiveComponent

  @impl LiveComponent
  def update(%{account: account, action: action, title: title} = params, socket) do
    socket =
      socket
      |> assign(:account, account)
      |> assign(:funds, list_funds(account))
      |> assign(:live_action, action)
      |> assign(:page_title, title)
      |> apply_action(action, params)

    {:ok, socket}
  end

  # @impl LiveComponent
  # def handle_params(params, _url, socket) do
  #   {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  # end

  # defp apply_action(socket, :edit_fund, %{"id" => id}) do
  #   socket
  #   |> assign(:fund, Funds.get_fund!(id))
  # end

  defp apply_action(socket, :new_fund, _params) do
    socket
    |> assign(:fund, %Fund{})
  end

  defp apply_action(socket, _action, _params) do
    assign(socket, :fund, nil)
  end

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
