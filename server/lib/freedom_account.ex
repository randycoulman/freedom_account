defmodule FreedomAccount do
  @moduledoc """
  FreedomAccount domain and business logic.
  """

  use Knigge,
    config_key: :freedom_account,
    default: __MODULE__.Impl,
    otp_app: :freedom_account

  alias FreedomAccount.Accounts
  alias FreedomAccount.Authentication
  alias FreedomAccount.Funds

  @type account :: Accounts.account()
  @type account_params :: Accounts.account_params()
  @type fund :: Funds.fund()
  @type update_error :: Accounts.update_error()
  @type user :: Authentication.user()
  @type user_id :: Authentication.user_id()
  @type username :: Authentication.username()

  @callback authenticate(username :: username) :: {:ok, user} | {:error, :unauthorized}
  @callback find_user(id :: user_id) :: {:ok, user} | {:error, :not_found}
  @callback list_funds(account :: account) :: [fund]
  @callback my_account(user :: user) :: {:ok, account} | {:error, :not_found}
  @callback update_account(params :: account_params) :: {:ok, account} | {:error, update_error}
end

defmodule FreedomAccount.Impl do
  @moduledoc false

  alias FreedomAccount.Accounts
  alias FreedomAccount.Funds
  alias FreedomAccount.Authentication

  @behaviour FreedomAccount

  @impl FreedomAccount
  defdelegate authenticate(username), to: Authentication

  @impl FreedomAccount
  defdelegate find_user(user_id), to: Authentication

  @impl FreedomAccount
  defdelegate list_funds(account), to: Funds

  @impl FreedomAccount
  defdelegate my_account(user), to: Accounts, as: :account_for_user

  @impl FreedomAccount
  defdelegate update_account(params), to: Accounts
end
