defmodule FreedomAccountWeb.FundLive.Show do
  @moduledoc false
  use FreedomAccountWeb, :live_view

  alias FreedomAccount.Funds
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

  defp apply_action(socket, _action, _params) do
    fund = socket.assigns.fund

    assign(socket, :page_title, "#{fund.icon} #{fund.name}")
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <.header>
      <%= @fund.icon %> <%= @fund.name %>
      <%!-- <:actions>
        <.link patch={~p"/funds/#{@fund}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit fund</.button>
        </.link>
      </:actions> --%>
    </.header>

    <.back navigate={~p"/funds"}>Back to Funds</.back>

    <%!-- <.modal :if={@live_action == :edit} id="fund-modal" show on_cancel={JS.patch(~p"/funds/#{@fund}")}>
      <.live_component
        module={FreedomAccountWeb.FundLive.FormComponent}
        id={@fund.id}
        title={@page_title}
        action={@live_action}
        fund={@fund}
        navigate={~p"/funds/#{@fund}"}
      />
    </.modal> --%>
    """
  end

  # defp page_title(:show), do: "Show Fund"
  # defp page_title(:edit), do: "Edit Fund"
end
