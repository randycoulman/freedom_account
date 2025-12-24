defmodule FreedomAccountWeb.FundLive.Index do
  @moduledoc false
  use FreedomAccountWeb, :live_view

  import FreedomAccountWeb.AccountBar, only: [account_bar: 1]
  import FreedomAccountWeb.AccountTabs, only: [account_tabs: 1]
  import FreedomAccountWeb.FundCard, only: [fund_card: 1]

  alias FreedomAccount.Error
  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund
  alias FreedomAccountWeb.Layouts
  alias Phoenix.LiveView

  @impl LiveView
  def handle_params(_params, _url, socket) do
    socket
    |> assign(:page_title, "Funds")
    |> noreply()
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.account_bar account={@account} balance={@account_balance} return_to="funds" />
      <.account_tabs active={:funds} funds_balance={@funds_balance} loans_balance={@loans_balance} />
      <div class="flex flex-row gap-2 justify-end py-4">
        <.button navigate={~p"/funds/regular_deposit"}>
          <.icon name="hero-folder-plus-mini" /> Regular Deposit
        </.button>
        <.button navigate={~p"/funds/regular_withdrawal"}>
          <.icon name="hero-folder-minus-mini" /> Regular Withdrawal
        </.button>
        <.button navigate={~p"/funds/budget"}>
          <.icon name="hero-chart-pie-mini" /> Budget
        </.button>
        <.button navigate={~p"/funds/activate"}>
          <.icon name="hero-archive-box-mini" /> Activate/Deactivate
        </.button>
        <.button navigate={~p"/funds/new"}>
          <.icon name="hero-plus-circle-mini" /> Add Fund
        </.button>
      </div>

      <div class="flex flex-col gap-2 items-center">
        <div :if={@funds == []} class="mx-auto p-4" id="no-funds">
          This account has no funds yet. Use the Add Fund button to add one.
        </div>
        <.fund_card
          :for={fund <- @funds}
          class="hover:cursor-pointer"
          id={"funds-#{fund.id}"}
          fund={fund}
          phx-click={JS.navigate(~p"/funds/#{fund}")}
        />
      </div>
    </Layouts.app>
    """
  end

  @impl LiveView
  def handle_event("delete", %{"id" => id}, socket) do
    with {:ok, fund} <- fetch_fund(socket, id),
         :ok <- Funds.delete_fund(fund) do
      noreply(socket)
    else
      {:error, error} ->
        socket
        |> put_flash(:error, Exception.message(error))
        |> noreply()
    end
  end

  defp fetch_fund(socket, id) do
    %{funds: funds} = socket.assigns

    with %Fund{} = fund <- Enum.find(funds, {:error, Error.not_found(details: %{id: id}, entity: Fund)}, &(&1.id == id)) do
      {:ok, fund}
    end
  end
end
