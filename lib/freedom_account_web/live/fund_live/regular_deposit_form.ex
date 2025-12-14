defmodule FreedomAccountWeb.FundLive.RegularDepositForm do
  @moduledoc """
  For making a regular deposit on a given date.
  """
  use FreedomAccountWeb, :live_view

  alias Ecto.Changeset
  alias FreedomAccount.Error.InvariantError
  alias FreedomAccount.LocalTime
  alias FreedomAccount.Transactions
  alias Phoenix.LiveView

  defmodule Inputs do
    @moduledoc false
    use TypedEctoSchema

    import Changeset

    alias Ecto.Schema

    @type attrs :: %{optional(:date) => Date.t()}

    typed_embedded_schema do
      field :date, :date
    end

    @spec changeset(Changeset.t() | Schema.t(), attrs()) :: Changeset.t()
    def changeset(inputs, attrs) do
      inputs
      |> cast(attrs, [:date])
      |> validate_required([:date])
    end
  end

  @impl LiveView
  def mount(_params, _session, socket) do
    inputs = %Inputs{date: LocalTime.today()}
    changeset = Inputs.changeset(inputs, %{})

    socket
    |> assign(:page_title, "Regular Deposit")
    |> assign(:inputs, inputs)
    |> assign(:form, to_form(changeset))
    |> ok()
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.standard_form
        class="max-w-sm"
        for={@form}
        id="regular-deposit-form"
        phx-change="validate"
        phx-submit="save"
        title={@page_title}
      >
        <.input field={@form[:date]} label="Date" phx-debounce="blur" type="date" />
        <:actions>
          <.button phx-disable-with="Saving..." type="submit" variant="primary">
            <.icon name="hero-check-circle-mini" /> Make Deposit
          </.button>
          <.button navigate={~p"/funds"}>Cancel</.button>
        </:actions>
      </.standard_form>
    </Layouts.app>
    """
  end

  @impl LiveView
  def handle_event("validate", params, socket) do
    %{"inputs" => input_params} = params
    changeset = Inputs.changeset(socket.assigns.inputs, input_params)

    socket
    |> assign(:form, to_form(changeset, action: :validate))
    |> noreply()
  end

  def handle_event("save", params, socket) do
    %{"inputs" => input_params} = params
    changeset = Inputs.changeset(socket.assigns.inputs, input_params)

    with {:ok, updated_inputs} <- Changeset.apply_action(changeset, :save),
         {:ok, _transaction} <-
           Transactions.regular_deposit(socket.assigns.account, updated_inputs.date, socket.assigns.funds) do
      socket
      |> put_flash(:info, "Regular deposit successful")
      |> push_navigate(to: ~p"/funds")
      |> noreply()
    else
      {:error, %Changeset{} = changeset} ->
        socket
        |> assign(:form, to_form(changeset))
        |> noreply()

      {:error, %InvariantError{} = error} ->
        socket
        |> put_flash(:error, Exception.message(error))
        |> noreply()
    end
  end
end
