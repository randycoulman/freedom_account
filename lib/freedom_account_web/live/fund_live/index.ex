defmodule FreedomAccountWeb.FundLive.Index do
  @moduledoc false
  use FreedomAccountWeb, :live_component

  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund
  alias FreedomAccountWeb.FundLive.Form
  alias Phoenix.LiveComponent

  @impl LiveComponent
  def update(assigns, socket) do
    %{account: account, action: action, title: title} = assigns

    socket =
      socket
      |> assign(:account, account)
      |> assign(:funds, list_funds(account))
      |> assign(:live_action, action)
      |> assign(:page_title, title)
      |> apply_action(action, assigns)

    {:ok, socket}
  end

  @impl LiveComponent
  def render(assigns) do
    ~H"""
    <article>
      <.header>
        Funds
        <:actions>
          <.link patch={~p"/funds/new"}>
            <.button>
              <.icon name="hero-plus-circle-mini" /> Add Fund
            </.button>
          </.link>
        </:actions>
      </.header>

      <%!-- <.table id="funds" rows={@funds} row_click={&JS.navigate(~p"/funds/#{&1}")}> --%>
      <.table :if={@funds != []} id="funds" row_id={&"funds-#{&1.id}"} rows={@funds}>
        <:col :let={fund} label="Icon"><%= fund.icon %></:col>
        <:col :let={fund} label="Name"><%= fund.name %></:col>
        <:action :let={fund}>
          <%!-- <div class="sr-only">
          <.link navigate={~p"/funds/#{fund}"}>Show</.link>
        </div> --%>
          <.link patch={~p"/funds/#{fund}/edit"}>
            <.icon name="hero-pencil-square-mini" /> Edit
          </.link>
        </:action>
        <:action :let={fund}>
          <.link
            phx-click={JS.push("delete", value: %{fund_id: fund.id})}
            data-confirm="Are you sure?"
            phx-target={@myself}
          >
            <.icon name="hero-trash-mini" /> Delete
          </.link>
        </:action>
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

  defp apply_action(socket, :edit_fund, assigns) do
    %{fund_id: id} = assigns

    case Funds.fetch_fund(id) do
      {:ok, %Fund{} = fund} ->
        assign(socket, :fund, fund)

      {:error, :not_found} ->
        put_flash(socket, :error, "Fund is no longer present")
    end
  end

  defp apply_action(socket, :new_fund, _assigns) do
    assign(socket, :fund, %Fund{})
  end

  defp apply_action(socket, _action, _assigns) do
    assign(socket, :fund, nil)
  end

  @impl LiveComponent
  def handle_event("delete", %{"fund_id" => id}, socket) do
    with {:ok, fund} <- Funds.fetch_fund(id),
         :ok <- Funds.delete_fund(fund) do
      {:noreply, assign(socket, :funds, list_funds(socket.assigns.account))}
    else
      {:error, error} ->
        {:noreply, put_flash(socket, :error, "Unable to delete fund: #{error}")}
    end
  end

  defp list_funds(account) do
    account
    |> Funds.list_funds()
    |> Enum.sort_by(& &1.name)
  end
end
