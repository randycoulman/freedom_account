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
  @type fund :: Funds.fund()

  @callback list_funds(account) :: {:ok, [fund]} | {:error, term}
  @callback my_account :: {:ok, account} | {:error, :not_found}
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
end
