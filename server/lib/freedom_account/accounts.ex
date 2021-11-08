defmodule FreedomAccount.Accounts do
  alias FreedomAccount.Accounts.Account

  @type account :: Account.t()

  @fake_account Account.new("Initial Account")

  @spec only_account :: {:ok, account} | {:error, term}
  def only_account do
    {:ok, @fake_account}
  end
end
