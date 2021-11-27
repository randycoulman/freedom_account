defmodule FreedomAccountWeb.Authentication do
  @moduledoc """
  Authenticate users to provide access to the application.
  """

  use Guardian, otp_app: :freedom_account

  alias Absinthe.Blueprint
  alias FreedomAccount.Authentication.User
  alias Plug.Conn

  @type context :: map()

  @context_key :authentication

  @spec absinthe_before_send(conn :: Conn.t(), blueprint :: Blueprint.t()) :: Conn.t()
  def absinthe_before_send(conn, %Blueprint{} = blueprint) do
    context = blueprint.execution.context

    case Map.fetch(context, @context_key) do
      {:ok, nil} -> sign_out(conn)
      {:ok, user} -> sign_in(conn, user)
      :error -> conn
    end
  end

  @spec current_user(conn :: Conn.t()) :: FreedomAccount.user() | nil
  def current_user(conn) do
    __MODULE__.Plug.current_resource(conn)
  end

  @spec note_signed_in(context :: context, user :: FreedomAccount.user()) :: context
  def note_signed_in(context, user) do
    Map.put(context, @context_key, user)
  end

  @spec note_signed_out(context :: context) :: context
  def note_signed_out(context) do
    Map.put(context, @context_key, nil)
  end

  @spec sign_in(conn :: Conn.t(), user :: FreedomAccount.user()) :: Conn.t()
  def sign_in(conn, user) do
    __MODULE__.Plug.sign_in(conn, user)
  end

  @spec sign_out(conn :: Conn.t()) :: Conn.t()
  def sign_out(conn) do
    __MODULE__.Plug.sign_out(conn)
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
