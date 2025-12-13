defmodule FreedomAccountWeb.FundLive.SettingsForm do
  @moduledoc false
  use FreedomAccountWeb, :live_view

  alias Ecto.Changeset
  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund
  alias FreedomAccountWeb.Params
  alias Phoenix.LiveView

  @impl LiveView
  def mount(_params, _session, socket) do
    fund = %Fund{}
    changeset = Funds.change_fund(fund)

    socket
    |> assign(:form, to_form(changeset))
    |> assign(:fund, fund)
    |> assign(:page_title, "Add Fund")
    |> ok()
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <.standard_form
      class="max-w-sm"
      for={@form}
      id="fund-form"
      phx-change="validate"
      phx-submit="save"
      title={@page_title}
    >
      <.input field={@form[:icon]} label="Icon" phx-debounce="blur" type="text" />
      <.input field={@form[:name]} label="Name" phx-debounce="blur" type="text" />
      <.input field={@form[:budget]} label="Budget" phx-debounce="blur" type="text" />
      <.input field={@form[:times_per_year]} label="Times/Year" phx-debounce="blur" type="text" />
      <:actions>
        <.button phx-disable-with="Saving..." type="submit" variant="primary">
          <.icon name="hero-check-circle-mini" /> Save Fund
        </.button>
      </:actions>
      <:actions>
        <.button navigate={~p"/funds"}>Cancel</.button>
      </:actions>
    </.standard_form>
    """
  end

  @impl LiveView
  def handle_event("validate", params, socket) do
    %{"fund" => fund_params} = params
    changeset = Funds.change_fund(socket.assigns.fund, fund_params)

    socket
    |> assign(:form, to_form(changeset, action: :validate))
    |> noreply()
  end

  def handle_event("save", params, socket) do
    %{"fund" => fund_params} = params

    save_fund(socket, socket.assigns.live_action, Params.atomize_keys(fund_params))
  end

  # defp save_fund(socket, :edit, fund_params) do
  #   %{fund: fund, return_path: return_path} = socket.assigns

  #   case Funds.update_fund(fund, fund_params) do
  #     {:ok, _fund} ->
  #       socket
  #       |> put_flash(:info, "Fund updated successfully")
  #       |> push_patch(to: return_path)
  #       |> noreply()

  #     {:error, %Changeset{} = changeset} ->
  #       socket
  #       |> assign_form(changeset)
  #       |> noreply()
  #   end
  # end

  defp save_fund(socket, :new, fund_params) do
    case Funds.create_fund(socket.assigns.account, fund_params) do
      {:ok, _fund} ->
        socket
        |> put_flash(:info, "Fund created successfully")
        |> push_navigate(to: ~p"/funds")
        |> noreply()

      {:error, %Changeset{} = changeset} ->
        socket
        |> assign(:form, to_form(changeset))
        |> noreply()
    end
  end
end
