defmodule FreedomAccountWeb.FundLive.Show do
  @moduledoc false
  # use FreedomAccountWeb, :live_view

  # alias FreedomAccount.Funds

  # @impl LiveView
  # def mount(_params, _session, socket) do
  #   {:ok, socket}
  # end

  # @impl LiveView
  # def handle_params(%{"id" => id}, _, socket) do
  #   {:noreply,
  #    socket
  #    |> assign(:page_title, page_title(socket.assigns.live_action))
  #    |> assign(:fund, Funds.get_fund!(id))}
  # end

  # @impl LiveView
  # def render(assigns) do
  #   ~H"""
  #   <.header>
  #     Fund <%= @fund.id %>
  #     <:subtitle>This is a fund record from your database.</:subtitle>
  #     <:actions>
  #       <.link patch={~p"/funds/#{@fund}/show/edit"} phx-click={JS.push_focus()}>
  #         <.button>Edit fund</.button>
  #       </.link>
  #     </:actions>
  #   </.header>

  #   <.list>
  #     <:item title="Icon"><%= @fund.icon %></:item>
  #     <:item title="Name"><%= @fund.name %></:item>
  #   </.list>

  #   <.back navigate={~p"/funds"}>Back to funds</.back>

  #   <.modal :if={@live_action == :edit} id="fund-modal" show on_cancel={JS.patch(~p"/funds/#{@fund}")}>
  #     <.live_component
  #       module={FreedomAccountWeb.FundLive.FormComponent}
  #       id={@fund.id}
  #       title={@page_title}
  #       action={@live_action}
  #       fund={@fund}
  #       navigate={~p"/funds/#{@fund}"}
  #     />
  #   </.modal>
  #   """
  # end

  # defp page_title(:show), do: "Show Fund"
  # defp page_title(:edit), do: "Edit Fund"
end
