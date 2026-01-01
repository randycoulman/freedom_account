defmodule FreedomAccountWeb.LoanLive.Index do
  @moduledoc false
  use FreedomAccountWeb, :live_view

  import FreedomAccountWeb.AccountBar, only: [account_bar: 1]
  import FreedomAccountWeb.AccountTabs, only: [account_tabs: 1]
  import FreedomAccountWeb.LoanCard, only: [loan_card: 1]

  alias FreedomAccount.Error
  alias FreedomAccount.Loans
  alias FreedomAccount.Loans.Loan
  alias FreedomAccountWeb.Layouts
  alias Phoenix.LiveView

  @impl LiveView
  def handle_params(_params, _url, socket) do
    socket
    |> assign(:page_title, "Loans")
    |> noreply()
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.account_bar account={@account} balance={@account_balance} return_to="loans" />
      <.account_tabs active={:loans} funds_balance={@funds_balance} loans_balance={@loans_balance} />
      <div class="flex flex-row gap-2 justify-end py-4">
        <div class="dropdown dropdown-end dropdown-hover">
          <.button>
            <.icon name="hero-bars-3-mini" />
          </.button>
          <ul class="dropdown-content menu bg-base-100 rounded-box shadow-sm space-y-1 z-1">
            <li>
              <.button navigate={~p"/loans/activate"}>
                <.icon name="hero-archive-box-mini" /> Activate/Deactivate
              </.button>
            </li>
            <li>
              <.button navigate={~p"/loans/new"}>
                <.icon name="hero-plus-circle-mini" /> Add Loan
              </.button>
            </li>
          </ul>
        </div>
      </div>

      <div class="flex flex-col gap-2 items-center">
        <div :if={@loans == []} class="mx-auto p-4" id="no-loans">
          This account has no active loans. Use the Add Loan button to add one.
        </div>
        <.loan_card
          :for={loan <- @loans}
          class="hover:cursor-pointer"
          id={"loans-#{loan.id}"}
          loan={loan}
          phx-click={JS.navigate(~p"/loans/#{loan}")}
        />
      </div>
    </Layouts.app>
    """
  end

  @impl LiveView
  def handle_event("delete", %{"id" => id}, socket) do
    with {:ok, loan} <- fetch_loan(socket, id),
         :ok <- Loans.delete_loan(loan) do
      noreply(socket)
    else
      {:error, error} ->
        socket
        |> put_flash(:error, Exception.message(error))
        |> noreply()
    end
  end

  defp fetch_loan(socket, id) do
    %{loans: loans} = socket.assigns

    with %Loan{} = loan <- Enum.find(loans, {:error, Error.not_found(details: %{id: id}, entity: Fund)}, &(&1.id == id)) do
      {:ok, loan}
    end
  end
end
