defmodule FreedomAccountWeb.FundLive.Show do
  @moduledoc false
  use FreedomAccountWeb, :live_view

  alias FreedomAccount.Funds
  alias FreedomAccountWeb.FundLive.Form
  alias Phoenix.LiveView

  @impl LiveView
  def handle_params(%{"id" => id} = params, _url, socket) do
    case Funds.fetch_fund(id) do
      {:ok, fund} ->
        {:noreply,
         socket
         |> assign(:fund, fund)
         |> apply_action(socket.assigns.live_action, params)}

      {:error, :not_found} ->
        {:noreply,
         socket
         |> put_flash(:error, "Fund not found")
         |> push_navigate(to: ~p"/funds")}
    end
  end

  defp apply_action(socket, :edit, _params) do
    assign(socket, :page_title, "Edit Fund")
  end

  defp apply_action(socket, _action, _params) do
    fund = socket.assigns.fund

    assign(socket, :page_title, "#{fund.icon} #{fund.name}")
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <.header>
      <%= @fund.icon %> <%= @fund.name %>
      <:actions>
        <.link patch={~p"/funds/#{@fund}/show/edit"} phx-click={JS.push_focus()}>
          <.button>
            <.icon name="hero-pencil-square-mini" /> Edit Details
          </.button>
        </.link>
      </:actions>
    </.header>

    <.back navigate={~p"/funds"}>Back to Funds</.back>

    <.modal :if={@live_action == :edit} id="fund-modal" show on_cancel={JS.patch(~p"/funds/#{@fund}")}>
      <.live_component
        account={@account}
        action={@live_action}
        fund={@fund}
        id={@fund.id}
        module={Form}
        patch={~p"/funds/#{@fund}"}
        title={@page_title}
      />
    </.modal>
    """
  end
end
