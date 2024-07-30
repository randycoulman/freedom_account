defmodule Mix.Tasks.Import do
  @shortdoc "Imports legacy data"
  @moduledoc "Imports data from original FreedomAccount application."
  use Boundary, classify_to: FreedomAccount.Mix
  use Mix.Task

  alias FreedomAccount.Accounts
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Error
  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.Transactions
  alias NimbleCSV.RFC4180, as: CSV

  @requirements ["app.start"]

  @impl Mix.Task
  def run(args) do
    [directory] = args

    account = Accounts.only_account()

    with {:ok, account, default_fund_name} <- import_account_settings(account, directory),
         {:ok, funds} <- import_funds(account, directory),
         {:ok, default_fund} <- find_fund(funds, default_fund_name),
         :ok <- import_fund_transactions(account, funds, directory),
         # Do this last to avoid overdraft coverage kicking in during import
         {:ok, _account} <- update_default_fund(account, default_fund) do
      Mix.shell().info("✅ Import completed successfully!")
    else
      {:error, error} ->
        Mix.shell().error("❌ Failed to import: #{inspect(error)}")
    end
  end

  defp import_account_settings(%Account{} = account, directory) do
    Mix.shell().info("⚙️ Importing account settings...")

    with {:ok, settings} <- load_account_settings(directory),
         {:ok, account} <- Accounts.update_account(account, settings) do
      {:ok, account, settings[:default_fund_name]}
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

  defp import_funds(%Account{} = account, directory) do
    Mix.shell().info("💰 Importing funds...")

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

  defp update_default_fund(%Account{} = account, %Fund{} = fund) do
    Mix.shell().info("🫵 Updating default fund...")
    Accounts.update_account(account, %{default_fund_id: fund.id})
  end

  defp import_fund_transactions(%Account{} = account, funds, directory) do
    Mix.shell().info("📓 Importing fund transactions...")

    directory
    |> Path.join("categoryTransactions.csv")
    |> File.stream!()
    |> CSV.parse_stream()
    |> Stream.each(fn [fund_name, date, memo, amount] ->
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
          Transactions.deposit(%{
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
    |> Stream.run()
  end

  defp find_fund(funds, name) do
    case Enum.find(funds, :none, &(&1.name == name)) do
      %Fund{} = fund -> {:ok, fund}
      :none -> {:error, Error.not_found(details: %{name: name}, entity: Fund)}
    end
  end
end
