defmodule FreedomAccountWeb.FundLive.Index do
  @moduledoc false
  use FreedomAccountWeb, :live_component

  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund
  alias FreedomAccountWeb.FundLive.Form
  alias Phoenix.LiveComponent

  @impl LiveComponent
  def update(%{account: account, action: action, title: title} = assigns, socket) do
    socket =
      socket
      |> assign(:account, account)
      |> assign(:funds, list_funds(account))
      |> assign(:live_action, action)
      |> assign(:page_title, title)
      |> apply_action(action, assigns)

    {:ok, socket}
  end

  # @impl LiveComponent
  # def handle_params(params, _url, socket) do
  #   {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  # end

  @impl LiveComponent
  def render(assigns) do
    ~H"""
    <article>
      <.header>
        Funds
        <:actions>
          <.link patch={~p"/funds/new"}>
            <.button>Add Fund</.button>
          </.link>
        </:actions>
      </.header>

      <%!-- <.table id="funds" rows={@funds} row_click={&JS.navigate(~p"/funds/#{&1}")}> --%>
      <.table :if={@funds != []} id="funds" rows={@funds}>
        <:col :let={fund} label="Icon"><%= fund.icon %></:col>
        <:col :let={fund} label="Name"><%= fund.name %></:col>
        <%!-- <:action :let={fund}>
        <div class="sr-only">
          <.link navigate={~p"/funds/#{fund}"}>Show</.link>
        </div>
        <.link patch={~p"/funds/#{fund}/edit"}>Edit</.link>
      </:action>
      <:action :let={fund}>
        <.link phx-click={JS.push("delete", value: %{id: fund.id})} data-confirm="Are you sure?">
          Delete
        </.link>
      </:action> --%>
      </.table>
      <div :if={@funds == []} id="no-funds">
        This account has no funds yet. Use the Add Fund button to add one.
      </div>

      <.modal
        :if={@live_action in [:new_fund, :edit_fund]}
        id="fund-modal"
        show
        on_cancel={JS.patch(~p"/")}
      >
        <.live_component
          account={@account}
          action={@live_action}
          fund={@fund}
          id={@fund.id || :new}
          module={Form}
          navigate={~p"/"}
          title={@page_title}
        />
      </.modal>
    </article>
    """
  end

  # defp apply_action(socket, :edit_fund, %{"id" => id}) do
  #   socket
  #   |> assign(:fund, Funds.get_fund!(id))
  # end

  defp apply_action(socket, :new_fund, _assigns) do
    assign(socket, :fund, %Fund{})
  end

  defp apply_action(socket, _action, _assigns) do
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
