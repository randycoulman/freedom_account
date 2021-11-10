defmodule FreedomAccount do
  @moduledoc """
  FreedomAccount domain and business logic.
  """

  use Knigge,
    config_key: :freedom_account,
    default: __MODULE__.Impl,
    otp_app: :freedom_account

  alias FreedomAccount.Accounts
  alias FreedomAccount.Funds

  @type account :: Accounts.account()
  @type account_params :: Accounts.account_params()
  @type fund :: Funds.fund()
  @type update_error :: Accounts.update_error()

  @callback list_funds(account :: account) :: [fund]
  @callback my_account :: {:ok, account} | {:error, :not_found}
  @callback update_account(params :: account_params) :: {:ok, account} | {:error, update_error}
end

defmodule FreedomAccount.Impl do
  @moduledoc false

  alias FreedomAccount.Accounts
  alias FreedomAccount.Funds

  @behaviour FreedomAccount

  @impl FreedomAccount
  defdelegate list_funds(account), to: Funds

  @impl FreedomAccount
  defdelegate my_account, to: Accounts, as: :only_account

  @impl FreedomAccount
  defdelegate update_account(params), to: Accounts
end
