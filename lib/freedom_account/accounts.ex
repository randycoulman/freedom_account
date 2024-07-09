defmodule FreedomAccount.Accounts do
  @moduledoc """
  Context for working with Freedom Accounts.
  """

  alias Ecto.Changeset
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Error.NotFoundError
  alias FreedomAccount.PubSub
  alias FreedomAccount.Repo

  @spec only_account :: Account.t()
  def only_account do
    case Repo.fetch_one(Account) do
      {:ok, account} ->
        account

      {:error, %NotFoundError{}} ->
        {:ok, account} = create_account(%{deposits_per_year: 24, name: "Initial Account"})
        account
    end
  end

  @spec create_account(Account.attrs()) :: {:ok, Account.t()} | {:error, Changeset.t()}
  def create_account(attrs \\ %{}) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  @spec pubsub_topic :: PubSub.topic()
  def pubsub_topic, do: ProcessTree.get(:account_topic, default: "account")

  @spec update_account(Account.t(), Account.attrs()) ::
          {:ok, Account.t()} | {:error, Changeset.t()}
  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
    |> PubSub.broadcast(pubsub_topic(), :account_updated)
  end

  @spec change_account(Account.t(), Account.attrs()) :: Changeset.t()
  def change_account(%Account{} = account, attrs \\ %{}) do
    Account.changeset(account, attrs)
  end
end
