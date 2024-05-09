defmodule FreedomAccount.Transactions do
  @moduledoc """
  Context for working with transactions in a Freedom Account.
  """
  alias Ecto.Changeset
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.Repo
  alias FreedomAccount.Transactions.LineItem
  alias FreedomAccount.Transactions.Transaction

  @spec change_transaction(Transaction.t(), Transaction.attrs()) :: Changeset.t()
  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end

  @spec deposit(Transaction.attrs()) :: {:ok, Transaction.t()} | {:error, Changeset.t()}
  def deposit(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  @spec new_deposit(Fund.t()) :: Transaction.partial()
  def new_deposit(fund) do
    %Transaction{
      line_items: [%LineItem{fund_id: fund.id}]
    }
  end
end
