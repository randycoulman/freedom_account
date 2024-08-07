defmodule FreedomAccountWeb.AccountBar.Form do
  @moduledoc """
  For editing account settings.
  """

  use FreedomAccountWeb, :live_component

  alias Ecto.Changeset
  alias FreedomAccount.Accounts
  alias FreedomAccount.Accounts.Account
  alias FreedomAccountWeb.Params
  alias Phoenix.LiveComponent
  alias Phoenix.LiveView
  alias Phoenix.LiveView.Socket

  attr :account, Account, required: true
  attr :funds, :list, required: true
  attr :return_path, :string, required: true

  @spec settings_form(Socket.assigns()) :: LiveView.Rendered.t()
  def settings_form(assigns) do
    ~H"""
    <.live_component id={@account.id} module={__MODULE__} {assigns} />
    """
  end

  @impl LiveComponent
  def update(assigns, socket) do
    %{account: account} = assigns
    changeset = Accounts.change_account(account)

    socket
    |> assign(assigns)
    |> assign_form(changeset)
    |> ok()
  end

  @impl LiveComponent
  def render(assigns) do
    options =
      for fund <- assigns.funds do
        {fund, fund.id}
      end

    assigns = assign(assigns, :options, [{"", nil} | options])

    ~H"""
    <div>
      <.header>
        Edit Account Settings
      </.header>

      <.simple_form
        for={@form}
        id="account-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
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
          <.button phx-disable-with="Saving..." type="submit">
            <.icon name="hero-check-circle-mini" /> Save Account
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl LiveComponent
  def handle_event("validate", %{"account" => account_params}, socket) do
    %{account: account} = socket.assigns

    changeset =
      account
      |> Accounts.change_account(account_params)
      |> Map.put(:action, :validate)

    socket
    |> assign_form(changeset)
    |> noreply()
  end

  def handle_event("save", %{"account" => account_params}, socket) do
    save_account(socket, Params.atomize_keys(account_params))
  end

  defp save_account(socket, account_params) do
    %{account: account, return_path: return_path} = socket.assigns

    case Accounts.update_account(account, account_params) do
      {:ok, _account} ->
        socket
        |> put_flash(:info, "Account updated successfully")
        |> push_patch(to: return_path)
        |> noreply()

      {:error, %Changeset{} = changeset} ->
        socket
        |> assign(:form, to_form(changeset))
        |> noreply()
    end
  end

  defp assign_form(socket, %Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
