defmodule FreedomAccountWeb.FundLive.ActivationForm do
  @moduledoc false
  use FreedomAccountWeb, :live_view

  alias Ecto.Changeset
  alias FreedomAccount.Funds
  alias Phoenix.LiveView

  @impl LiveView
  def mount(_params, _session, socket) do
    changeset = Funds.change_activation(socket.assigns.account)

    socket
    |> assign(:page_title, "Activate/Deactivate Funds")
    |> assign(:form, to_form(changeset))
    |> ok()
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.standard_form
        class="max-w-lg"
        for={@form}
        id="activation-form"
        phx-change="validate"
        phx-submit="save"
        title="Activate/Deactivate Funds"
      >
        <div class="grid justify-center">
          <.inputs_for :let={fund} field={@form[:funds]}>
            <.input field={fund[:active]} label={fund.data} type="checkbox" />
          </.inputs_for>
        </div>
        <:actions>
          <.button phx-disable-with="Updating..." type="submit" variant="primary">
            <.icon name="hero-check-circle-mini" /> Update Funds
          </.button>
        </:actions>
        <:actions>
          <.button navigate={~p"/funds"}>Cancel</.button>
        </:actions>
      </.standard_form>
    </Layouts.app>
    """
  end

  @impl LiveView
  def handle_event("validate", params, socket) do
    %{"activation" => activation_params} = params
    changeset = Funds.change_activation(socket.assigns.account, activation_params)

    socket
    |> assign(:form, to_form(changeset, action: :validate))
    |> noreply()
  end

  def handle_event("save", params, socket) do
    %{"activation" => activation_params} = params

    case Funds.update_activation(socket.assigns.account, activation_params) do
      {:ok, _updated_funds} ->
        socket
        |> put_flash(:info, "Funds updated successfully")
        |> push_navigate(to: ~p"/funds")
        |> noreply()

      {:error, %Changeset{} = changeset} ->
        socket
        |> assign(:form, to_form(changeset))
        |> noreply()
    end
  end
end
