defmodule FreedomAccountWeb.Resolvers.Authentication do
  @moduledoc """
  GraphQL resolvers for authentication.
  """

  use FreedomAccountWeb.Resolvers.Base

  alias FreedomAccount.Authentication.User
  alias FreedomAccountWeb.Authentication

  @type login_input :: %{username: username}
  @type user :: FreedomAccount.user()
  @type username :: FreedomAccount.username()

  @spec login(args :: login_input, resolution :: resolution) :: result(user)
  def login(%{username: username}, _resolution) do
    with {:ok, user} <- FreedomAccount.authenticate(username) do
      {:ok, user}
    end
  end

  @spec login_middleware(resolution :: resolution, config :: keyword) :: resolution
  def login_middleware(resolution, _config) do
    case resolution.value do
      %User{} = user ->
        Map.update!(resolution, :context, &Authentication.note_signed_in(&1, user))

      _value ->
        resolution
    end
  end

  @spec logout(args :: %{}, resolution :: resolution) :: result(boolean)
  def logout(_args, _resolution) do
    {:ok, true}
  end

  @spec logout_middleware(resolution :: resolution, config :: keyword) :: resolution
  def logout_middleware(resolution, _config) do
    case resolution.value do
      true ->
        Map.update!(resolution, :context, &Authentication.note_signed_out/1)

      _value ->
        resolution
    end
  end
end
