defmodule FreedomAccount.Accounts do
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Repo

  @type account :: Account.t()

  @spec only_account :: {:ok, account} | {:error, :not_found}
  def only_account do
    case Repo.one(Account) do
      nil -> {:error, :not_found}
      account -> {:ok, account}
    end
  end
end
