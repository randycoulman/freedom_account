defmodule FreedomAccountWeb.RegularDepositForm do
  @moduledoc """
  For making a regular deposit on a given date.
  """
  use FreedomAccountWeb, :live_component

  alias Ecto.Changeset
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Error.InvariantError
  alias FreedomAccount.Transactions
  alias Phoenix.LiveComponent
  alias Phoenix.LiveView
  alias Phoenix.LiveView.Socket

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

  attr :account, Account, required: true
  attr :funds, :list, required: true
  attr :return_path, :string, required: true

  @spec regular_deposit_form(Socket.assigns()) :: LiveView.Rendered.t()
  def regular_deposit_form(assigns) do
    ~H"""
    <.live_component id={@account.id} module={__MODULE__} {assigns} />
    """
  end

  @impl LiveComponent
  def update(assigns, socket) do
    inputs = %Inputs{date: Timex.today(:local)}
    changeset = Inputs.changeset(inputs, %{})

    socket
    |> assign(assigns)
    |> assign(:inputs, inputs)
    |> assign_form(changeset)
    |> ok()
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

    socket
    |> assign_form(changeset)
    |> noreply()
  end

  def handle_event("save", params, socket) do
    %{"inputs" => input_params} = params
    %{account: account, funds: funds, inputs: inputs, return_path: return_path} = socket.assigns

    changeset = Inputs.changeset(inputs, input_params)

    with {:ok, updated_inputs} <- Changeset.apply_action(changeset, :save),
         {:ok, _transaction} <- Transactions.regular_deposit(account, updated_inputs.date, funds) do
      socket
      |> put_flash(:info, "Regular deposit successful")
      |> push_patch(to: return_path)
      |> noreply()
    else
      {:error, %Changeset{} = changeset} ->
        socket
        |> assign_form(changeset)
        |> noreply()

      {:error, %InvariantError{} = error} ->
        socket
        |> put_flash(:error, Exception.message(error))
        |> noreply()
    end
  end

  defp assign_form(socket, %Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
