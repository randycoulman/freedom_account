defmodule FreedomAccount.Authentication do
  @moduledoc """
  Context for authenticating users.

  Because this is a personal app that will only run locally, we don't need a
  full-blown authentication system. However, in order to be able to isolate
  local development from automated tests, we have the concept of users so that
  Cypress tests and local browser testing can each have their own user/account.
  """

  alias FreedomAccount.Authentication.User
  alias FreedomAccount.Repo

  @type user :: User.t()
  @type user_id :: User.id()
  @type username :: User.name()

  @spec authenticate(username :: username) :: {:ok, user} | {:error, :unauthorized}
  def authenticate(username) do
    case Repo.get_by(User, name: username) do
      nil -> {:error, :unauthorized}
      user -> {:ok, user}
    end
  end

  @spec find_user(id :: user_id) :: {:ok, user} | {:error, :not_found}
  def find_user(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end
end
