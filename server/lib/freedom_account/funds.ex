defmodule FreedomAccount.Funds do
  @moduledoc """
  Context for working with funds in a Freedom Account.
  """

  alias Ecto.Changeset
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.Repo

  @type create_error :: Changeset.t()
  @type fund :: Fund.t()
  @type fund_params :: Fund.params()

  @spec create_fund(account :: Account.t(), params :: fund_params) ::
          {:ok, fund} | {:error, Changeset.t()}
  def create_fund(account, params) do
    account
    |> Ecto.build_assoc(:funds)
    |> Fund.changeset(params)
    |> Repo.insert()
  end

  @spec list_funds(account :: Account.t()) :: [fund]
  def list_funds(account) do
    account
    |> Ecto.assoc(:funds)
    |> Repo.all()
  end
end
