defmodule FreedomAccount.Users do
  @moduledoc """
  Context for working with users.

  Because this is a personal app that will only run locally, we don't need a
  full-blown authentication system. However, in order to be able to isolate
  local development from automated tests, we have the concept of users so that
  Cypress tests and local browser testing can each have their own user/account.
  """
end
