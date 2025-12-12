defmodule FreedomAccountWeb.LoanLive.FetchLoan do
  @moduledoc """
  Fetches the loan identified by the params and adds it to the assigns.

  If the loan can't be found, return to the loan list page.
  """
  use FreedomAccountWeb, :hook

  alias FreedomAccount.Loans.Loan
  alias Phoenix.LiveView.Socket

  @spec on_mount(atom(), map(), map(), Socket.t()) :: {:cont | :halt, Socket.t()}
  def on_mount(:default, params, _session, socket) do
    id = String.to_integer(params["id"])

    case Enum.find(socket.assigns.loans, :not_found, &(&1.id == id)) do
      %Loan{} = loan ->
        socket
        |> assign(:loan, loan)
        |> cont()

      :not_found ->
        socket
        |> put_flash(:error, "Loan not found")
        |> push_navigate(~p"/loans")
        |> halt()
    end
  end
end
