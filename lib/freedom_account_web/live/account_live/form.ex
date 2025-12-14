defmodule FreedomAccountWeb.AccountLive.Form do
  @moduledoc false
  use FreedomAccountWeb, :live_view

  alias Ecto.Changeset
  alias FreedomAccount.Accounts
  alias FreedomAccountWeb.Params
  alias Phoenix.LiveView

  @impl LiveView
  def mount(params, _session, socket) do
    changeset = Accounts.change_account(socket.assigns.account)

    socket
    |> assign(:page_title, "Edit Account Settings")
    |> assign(:return_to, return_to(params["return_to"]))
    |> assign(:form, to_form(changeset))
    |> ok()
  end

  @impl LiveView
  def render(assigns) do
    options =
      for fund <- assigns.funds do
        {fund, fund.id}
      end

    assigns = assign(assigns, :options, [{"", nil} | options])

    ~H"""
    <Layouts.app flash={@flash}>
      <.standard_form
        class="max-w-lg"
        for={@form}
        id="account-form"
        phx-change="validate"
        phx-submit="save"
        title={@page_title}
      >
        <.input field={@form[:name]} label="Name" phx-debounce="blur" type="text" />
        <.input
          field={@form[:deposits_per_year]}
          label="Deposits / year"
          phx-debounce="blur"
          type="number"
        />
        <.input
          field={@form[:default_fund_id]}
          id="default-fund"
          label="Default fund"
          options={@options}
          phx-debounce="blur"
          type="select"
        />
        <:actions>
          <.button phx-disable-with="Saving..." type="submit" variant="primary">
            <.icon name="hero-check-circle-mini" /> Save Account
          </.button>
        </:actions>
        <:actions>
          <.button navigate={return_path(@return_to)}>Cancel</.button>
        </:actions>
      </.standard_form>
    </Layouts.app>
    """
  end

  @impl LiveView
  def handle_event("validate", %{"account" => account_params}, socket) do
    changeset = Accounts.change_account(socket.assigns.account, account_params)

    socket
    |> assign(:form, to_form(changeset, action: :validate))
    |> noreply()
  end

  def handle_event("save", %{"account" => account_params}, socket) do
    save_account(socket, Params.atomize_keys(account_params))
  end

  defp return_path(:funds), do: ~p"/funds"
  defp return_path(:loans), do: ~p"/loans"
  defp return_path(:transactions), do: ~p"/transactions"

  defp return_to("funds"), do: :funds
  defp return_to("loans"), do: :loans
  defp return_to("transactions"), do: :transactions
  defp return_to(_other_or_nil), do: :funds

  defp save_account(socket, account_params) do
    case Accounts.update_account(socket.assigns.account, account_params) do
      {:ok, _account} ->
        socket
        |> put_flash(:info, "Account updated successfully")
        |> push_navigate(to: return_path(socket.assigns.return_to))
        |> noreply()

      {:error, %Changeset{} = changeset} ->
        socket
        |> assign(:form, to_form(changeset))
        |> noreply()
    end
  end
end
