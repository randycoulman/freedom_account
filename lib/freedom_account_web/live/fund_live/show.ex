defmodule FreedomAccountWeb.FundLive.Show do
  @moduledoc false
  use FreedomAccountWeb, :live_view

  import FreedomAccountWeb.FundList, only: [fund_list: 1]

  alias FreedomAccount.Funds
  alias FreedomAccountWeb.FundLive.Form
  alias Phoenix.LiveView

  @impl LiveView
  def handle_params(%{"id" => id} = params, _url, socket) do
    %{account: account, live_action: action} = socket.assigns

    case Funds.fetch_fund(account, id) do
      {:ok, fund} ->
        {:noreply,
         socket
         |> assign(:fund, fund)
         |> apply_action(action, params)}

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

  defp apply_action(socket, :edit_account, _params) do
    assign(socket, :page_title, "Edit Account Settings")
  end

  defp apply_action(socket, _action, _params) do
    %{fund: fund} = socket.assigns

    assign(socket, :page_title, "#{fund.icon} #{fund.name}")
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <.live_component
      account={@account}
      action={@live_action}
      edit_path={~p"/funds/#{@fund}/account"}
      id={@account.id}
      module={FreedomAccountWeb.Account.Show}
      return_path={~p"/funds/#{@fund}"}
    />
    <div class="flex h-screen">
      <aside class="hidden md:flex flex-col w-56 bg-slate-100">
        <.fund_list funds={@streams.funds} />
      </aside>
      <main class="flex flex-col flex-1 overflow-y-auto pl-2">
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
      </main>
    </div>

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
