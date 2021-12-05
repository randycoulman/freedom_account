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
  @type account_id :: Accounts.account_id()
  @type account_params :: Accounts.account_params()
  @type fund :: Funds.fund()
  @type fund_params :: Funds.fund_params()
  @type reset_error :: Accounts.update_error() | {:error, :unauthorized}
  @type update_error :: Accounts.update_error()
  @type user :: Authentication.user()
  @type user_id :: Authentication.user_id()
  @type username :: Authentication.username()

  @callback authenticate(username :: username) :: {:ok, user} | {:error, :unauthorized}
  @callback create_fund(account_id :: account_id, params :: fund_params) ::
              {:ok, fund} | {:error, :not_found | Funds.create_error()}
  @callback find_user(id :: user_id) :: {:ok, user} | {:error, :not_found}
  @callback list_funds(account :: account) :: [fund]
  @callback my_account(user :: user) :: {:ok, account} | {:error, :not_found}
  @callback reset_test_account :: :ok
  @callback update_account(params :: account_params) :: {:ok, account} | {:error, reset_error}
end

defmodule FreedomAccount.Impl do
  @moduledoc false

  alias FreedomAccount.Accounts
  alias FreedomAccount.Authentication
  alias FreedomAccount.Funds

  @behaviour FreedomAccount

  @test_username "cypress"

  @impl FreedomAccount
  defdelegate authenticate(username), to: Authentication

  @impl FreedomAccount
  def create_fund(account_id, params) do
    with {:ok, account} <- Accounts.find_account(account_id) do
      Funds.create_fund(account, params)
    end
  end

  @impl FreedomAccount
  defdelegate find_user(user_id), to: Authentication

  @impl FreedomAccount
  defdelegate list_funds(account), to: Funds

  @impl FreedomAccount
  defdelegate my_account(user), to: Accounts, as: :account_for_user

  @impl FreedomAccount
  def reset_test_account do
    with {:ok, test_user} <- authenticate(@test_username),
         {:ok, original_account} <- my_account(test_user) do
      Accounts.reset_account(original_account)
    end
  end

  @impl FreedomAccount
  defdelegate update_account(params), to: Accounts
end
