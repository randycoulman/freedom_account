defmodule FreedomAccountWeb.Authentication do
  @moduledoc """
  Authenticate users to provide access to the application.
  """

  use Guardian, otp_app: :freedom_account

  alias Absinthe.Blueprint
  alias FreedomAccount.Authentication.User
  alias Plug.Conn

  @spec absinthe_before_send(conn :: Conn.t(), blueprint :: Blueprint.t()) :: Conn.t()
  def absinthe_before_send(conn, %Blueprint{} = blueprint) do
    context = blueprint.execution.context

    if user = context[:sign_in] do
      sign_in(conn, user)
    else
      conn
    end
  end

  @spec current_user(conn :: Conn.t()) :: FreedomAccount.user() | nil
  def current_user(conn) do
    __MODULE__.Plug.current_resource(conn)
  end

  @spec sign_in(conn :: Conn.t(), user :: FreedomAccount.user()) :: Conn.t()
  def sign_in(conn, user) do
    __MODULE__.Plug.sign_in(conn, user)
  end

  @impl Guardian
  def resource_from_claims(%{"sub" => id}) do
    case FreedomAccount.find_user(id) do
      {:error, :not_found} -> {:error, :unauthorized}
      result -> result
    end
  end

  def resource_from_claims(_claims) do
    {:error, :unauthorized}
  end

  @impl Guardian
  def subject_for_token(%User{id: id}, _claims) do
    {:ok, id}
  end
end
