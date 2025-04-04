defmodule FreedomAccountWeb.FundLive.Form do
  @moduledoc false
  use FreedomAccountWeb, :live_component

  alias Ecto.Changeset
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund
  alias FreedomAccountWeb.Params
  alias Phoenix.LiveComponent
  alias Phoenix.LiveView
  alias Phoenix.LiveView.Socket

  attr :account, Account, required: true
  attr :action, :string, required: true
  attr :fund, Fund, required: true
  attr :return_path, :string, required: true
  attr :title, :string, required: true

  @spec settings_form(Socket.assigns()) :: LiveView.Rendered.t()
  def settings_form(assigns) do
    ~H"""
    <.live_component id={@fund.id || :new} module={__MODULE__} {assigns} />
    """
  end

  @impl LiveComponent
  def update(assigns, socket) do
    %{fund: fund} = assigns
    changeset = Funds.change_fund(fund)

    socket
    |> assign(assigns)
    |> assign_form(changeset)
    |> ok()
  end

  @impl LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>

      <.simple_form
        for={@form}
        id="fund-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:icon]} label="Icon" phx-debounce="blur" type="text" />
        <.input field={@form[:name]} label="Name" phx-debounce="blur" type="text" />
        <.input field={@form[:budget]} label="Budget" phx-debounce="blur" type="text" />
        <.input field={@form[:times_per_year]} label="Times/Year" phx-debounce="blur" type="text" />
        <:actions>
          <.button phx-disable-with="Saving..." type="submit">
            <.icon name="hero-check-circle-mini" /> Save Fund
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl LiveComponent
  def handle_event("validate", params, socket) do
    %{"fund" => fund_params} = params
    %{fund: fund} = socket.assigns

    changeset =
      fund
      |> Funds.change_fund(fund_params)
      |> Map.put(:action, :validate)

    socket
    |> assign_form(changeset)
    |> noreply()
  end

  def handle_event("save", params, socket) do
    %{"fund" => fund_params} = params
    %{action: action} = socket.assigns

    save_fund(socket, action, Params.atomize_keys(fund_params))
  end

  defp save_fund(socket, :edit, fund_params) do
    %{fund: fund, return_path: return_path} = socket.assigns

    case Funds.update_fund(fund, fund_params) do
      {:ok, _fund} ->
        socket
        |> put_flash(:info, "Fund updated successfully")
        |> push_patch(to: return_path)
        |> noreply()

      {:error, %Changeset{} = changeset} ->
        socket
        |> assign_form(changeset)
        |> noreply()
    end
  end

  defp save_fund(socket, :new, fund_params) do
    %{account: account, return_path: return_path} = socket.assigns

    case Funds.create_fund(account, fund_params) do
      {:ok, _fund} ->
        socket
        |> put_flash(:info, "Fund created successfully")
        |> push_patch(to: return_path)
        |> noreply()

      {:error, %Changeset{} = changeset} ->
        socket
        |> assign_form(changeset)
        |> noreply()
    end
  end

  defp assign_form(socket, %Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
