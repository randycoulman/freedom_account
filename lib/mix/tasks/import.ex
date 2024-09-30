defmodule Mix.Tasks.Import do
  @shortdoc "Imports legacy data"
  @moduledoc "Imports data from original FreedomAccount application."
  use Boundary, classify_to: FreedomAccount
  use Mix.Task

  alias FreedomAccount.Accounts
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Error
  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.Loans
  alias FreedomAccount.Loans.Loan
  alias FreedomAccount.Transactions
  alias NimbleCSV.RFC4180, as: CSV

  @requirements ["app.start"]
  @steps [:account_settings, :funds, :fund_transactions, :default_fund, :loans, :loan_transactions]

  @impl Mix.Task
  def run(args) do
    {opts, [directory]} = OptionParser.parse!(args, switches: [from: :string])

    steps =
      case opts[:from] do
        nil ->
          @steps

        from ->
          Enum.drop_while(@steps, &(to_string(&1) != from))
      end

    opts = [directory: directory, steps: steps]

    account = Accounts.only_account()

    with {:ok, account, default_fund_name} <- import_account_settings(account, opts),
         {:ok, funds} <- import_funds(account, opts),
         :ok <- import_fund_transactions(account, funds, opts),
         # Do this after fund transactions to avoid overdraft coverage kicking in during import
         {:ok, _account} <- update_default_fund(account, funds, default_fund_name, opts),
         {:ok, loans} <- import_loans(account, opts),
         :ok <- import_loan_transactions(account, loans, opts) do
      Mix.shell().info("✅ Import completed successfully!")
    else
      {:error, error} ->
        Mix.shell().error("❌ Failed to import: #{inspect(error)}")
    end
  end

  defp import_account_settings(%Account{} = account, opts) do
    if :account_settings in opts[:steps] do
      Mix.shell().info("⚙️ Importing account settings...")

      with {:ok, settings} <- load_account_settings(opts[:directory]),
           {:ok, account} <- Accounts.update_account(account, settings) do
        {:ok, account, settings[:default_fund_name]}
      end
    else
      Mix.shell().info("➖ Skipping account settings...")
      {:ok, account, nil}
    end
  end

  defp load_account_settings(directory) do
    settings =
      directory
      |> Path.join("account.csv")
      |> File.stream!()
      |> CSV.parse_stream()
      |> Stream.map(fn [name, deposits, default_fund_name] ->
        %{name: name, deposits_per_year: String.to_integer(deposits), default_fund_name: default_fund_name}
      end)
      |> Stream.take(1)
      |> Enum.to_list()
      |> hd()

    {:ok, settings}
  end

  defp import_funds(%Account{} = account, opts) do
    if :funds in opts[:steps] do
      Mix.shell().info("💰 Importing funds...")
      do_import_funds(account, opts[:directory])
    else
      Mix.shell().info("➖ Skipping funds...")
      {:ok, Funds.list_all_funds(account)}
    end
  end

  defp do_import_funds(%Account{} = account, directory) do
    funds =
      directory
      |> Path.join("categories.csv")
      |> File.stream!()
      |> CSV.parse_stream()
      |> Stream.map(fn [name, active, budget, times_per_year] ->
        %Money{} = budget = Money.parse(budget)
        active? = active == "true"

        {:ok, fund} =
          Funds.create_fund(account, %{
            budget: budget,
            icon: "❓",
            name: name,
            times_per_year: String.to_float(times_per_year)
          })

        fund = %{fund | current_balance: Money.zero(:usd)}

        if active? do
          fund
        else
          {:ok, fund} = Funds.deactivate_fund(fund)
          fund
        end
      end)
      |> Enum.to_list()

    {:ok, funds}
  end

  defp import_fund_transactions(%Account{} = account, funds, opts) do
    if :fund_transactions in opts[:steps] do
      Mix.shell().info("📓 Importing fund transactions...")
      do_import_fund_transactions(account, funds, opts[:directory])
    else
      Mix.shell().info("➖ Skipping fund transactions...")
      :ok
    end
  end

  defp do_import_fund_transactions(%Account{} = account, funds, directory) do
    directory
    |> Path.join("categoryTransactions.csv")
    |> File.stream!()
    |> CSV.parse_stream()
    |> Enum.each(fn [fund_name, date, memo, amount] ->
      date = Date.from_iso8601!(date)
      %Money{} = amount = Money.parse(amount)
      {:ok, fund} = find_fund(funds, fund_name)

      {:ok, _transaction} =
        if Money.negative?(amount) do
          Transactions.withdraw(account, %{
            date: date,
            memo: memo,
            line_items: [
              %{
                amount: Money.abs(amount),
                fund_id: fund.id
              }
            ]
          })
        else
          Transactions.deposit(account, %{
            date: date,
            memo: memo,
            line_items: [
              %{
                amount: amount,
                fund_id: fund.id
              }
            ]
          })
        end
    end)
  end

  defp update_default_fund(%Account{} = account, _funds, nil, _opts) do
    Mix.shell().info("➖ Skipping default fund; no default fund specified")
    {:ok, account}
  end

  defp update_default_fund(%Account{} = account, funds, default_fund_name, opts) do
    if :default_fund in opts[:steps] do
      Mix.shell().info("🫵 Updating default fund...")

      with {:ok, fund} <- find_fund(funds, default_fund_name) do
        Accounts.update_account(account, %{default_fund_id: fund.id})
      end
    else
      Mix.shell().info("➖ Skipping default fund...")
      {:ok, account}
    end
  end

  defp import_loans(%Account{} = account, opts) do
    if :loans in opts[:steps] do
      Mix.shell().info("🏦 Importing loans...")
      do_import_loans(account, opts[:directory])
    else
      Mix.shell().info("➖ Skipping loans...")
      {:ok, Loans.list_all_loans(account)}
    end
  end

  defp do_import_loans(%Account{} = account, directory) do
    funds =
      directory
      |> Path.join("loans.csv")
      |> File.stream!()
      |> CSV.parse_stream()
      |> Stream.map(fn [name, active] ->
        active? = active == "true"

        {:ok, loan} =
          Loans.create_loan(account, %{
            icon: "❓",
            name: name
          })

        loan = %{loan | current_balance: Money.zero(:usd)}

        if active? do
          loan
        else
          {:ok, loan} = Loans.deactivate_loan(loan)
          loan
        end
      end)
      |> Enum.to_list()

    {:ok, funds}
  end

  defp import_loan_transactions(%Account{} = account, loans, opts) do
    if :loan_transactions in opts[:steps] do
      Mix.shell().info("💰 Importing loan transactions...")
      do_import_loan_transactions(account, loans, opts[:directory])
    else
      Mix.shell().info("➖ Skipping loan transactions...")
      :ok
    end
  end

  defp do_import_loan_transactions(%Account{} = account, loans, directory) do
    directory
    |> Path.join("loanTransactions.csv")
    |> File.stream!()
    |> CSV.parse_stream()
    |> Enum.each(fn [loan_name, date, memo, amount] ->
      date = Date.from_iso8601!(date)
      %Money{} = amount = Money.parse(amount)
      {:ok, loan} = find_loan(loans, loan_name)

      {:ok, _transaction} =
        if Money.negative?(amount) do
          Transactions.lend(account, %{
            amount: Money.abs(amount),
            date: date,
            loan_id: loan.id,
            memo: memo
          })
        else
          Transactions.receive_payment(account, %{
            amount: amount,
            date: date,
            loan_id: loan.id,
            memo: memo
          })
        end
    end)
  end

  defp find_fund(funds, name) do
    case Enum.find(funds, :none, &(&1.name == name)) do
      %Fund{} = fund -> {:ok, fund}
      :none -> {:error, Error.not_found(details: %{name: name}, entity: Fund)}
    end
  end

  defp find_loan(loans, name) do
    case Enum.find(loans, :none, &(&1.name == name)) do
      %Loan{} = loan -> {:ok, loan}
      :none -> {:error, Error.not_found(details: %{name: name}, entity: Loan)}
    end
  end
end
