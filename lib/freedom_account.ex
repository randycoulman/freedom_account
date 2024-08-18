defmodule FreedomAccount do
  @moduledoc """
  FreedomAccount keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  use Boundary,
    exports: [
      Accounts,
      Accounts.Account,
      Balances,
      Error,
      {Error, []},
      Funds,
      Funds.Fund,
      Loans,
      Loans.Loan,
      MoneyUtils,
      Paging,
      PubSub,
      Transactions,
      Transactions.AccountTransaction,
      Transactions.LoanTransaction,
      Transactions.Transaction
    ]
end
