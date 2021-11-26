defmodule FreedomAccountWeb.Resolvers.User do
  @moduledoc """
  GraphQL resolvers for users.
  """

  use FreedomAccountWeb.Resolvers.Base

  alias FreedomAccount.Authentication.User

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
        Map.update!(resolution, :context, &Map.put(&1, :sign_in, user))

      _value ->
        resolution
    end
  end
end
