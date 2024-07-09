defmodule FreedomAccountWeb.RegularDepositForm do
  @moduledoc """
  For making a regular deposit on a given date.
  """
  use FreedomAccountWeb, :live_component

  alias Ecto.Changeset
  alias FreedomAccount.Error.InvariantError
  alias FreedomAccount.Transactions
  alias Phoenix.LiveComponent

  defmodule Inputs do
    @moduledoc false
    use TypedEctoSchema

    import Ecto.Changeset

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

  @impl LiveComponent
  def update(assigns, socket) do
    inputs = %Inputs{date: Timex.today(:local)}
    changeset = Inputs.changeset(inputs, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:inputs, inputs)
     |> assign_form(changeset)}
  end

  @impl LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.header>Regular Deposit</.header>
      <.simple_form
        for={@form}
        id="regular-deposit-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:date]} label="Date" phx-debounce="blur" type="date" />
        <:actions>
          <.button phx-disable-with="Saving..." type="submit">
            <.icon name="hero-check-folder-mini" /> Make Deposit
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl LiveComponent
  def handle_event("validate", params, socket) do
    %{"inputs" => input_params} = params
    %{inputs: inputs} = socket.assigns

    changeset =
      inputs
      |> Inputs.changeset(input_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", params, socket) do
    %{"inputs" => input_params} = params
    %{account: account, funds: funds, inputs: inputs, return_path: return_path} = socket.assigns

    changeset = Inputs.changeset(inputs, input_params)

    with {:ok, updated_inputs} <- Changeset.apply_action(changeset, :save),
         {:ok, _transaction} <- Transactions.regular_deposit(updated_inputs.date, funds, account.deposits_per_year) do
      {:noreply,
       socket
       |> put_flash(:info, "Regular deposit successful")
       |> push_patch(to: return_path)}
    else
      {:error, %Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}

      {:error, %InvariantError{} = error} ->
        {:noreply, put_flash(socket, :error, Exception.message(error))}
    end
  end

  defp assign_form(socket, %Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
