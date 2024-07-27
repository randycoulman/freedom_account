defmodule FreedomAccount.TransactionsTest do
  use FreedomAccount.DataCase, async: true

  import Assertions
  import Money.Sigil

  alias Ecto.Changeset
  alias FreedomAccount.Error.NotFoundError
  alias FreedomAccount.Factory
  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.MoneyUtils
  alias FreedomAccount.Paging
  alias FreedomAccount.PubSub
  alias FreedomAccount.Transactions
  alias FreedomAccount.Transactions.FundTransaction
  alias FreedomAccount.Transactions.LineItem
  alias FreedomAccount.Transactions.Transaction

  setup [:create_account, :create_fund]

  describe "creating a changeset for a Transaction" do
    test "returns the changeset", %{} do
      assert %Changeset{} = Transactions.change_transaction(%Transaction{})
    end

    test "computes an initial total" do
      %Changeset{} = changeset = Transactions.change_transaction(%Transaction{})
      assert Changeset.get_field(changeset, :total) == Money.zero(:usd)
    end

    test "recomputes the total with updated line items", %{fund: fund} do
      line_item_attrs = Factory.line_item_attrs(fund)
      valid_attrs = Factory.transaction_attrs(line_items: [line_item_attrs])

      %Changeset{} = changeset = Transactions.change_transaction(%Transaction{}, valid_attrs)

      assert Changeset.get_field(changeset, :total) == line_item_attrs[:amount]
    end
  end

  describe "making a deposit to a single fund" do
    test "creates a transaction and its line item with valid data", %{fund: fund} do
      line_item_attrs = Factory.line_item_attrs(fund)
      valid_attrs = Factory.transaction_attrs(line_items: [line_item_attrs])

      assert {:ok, %Transaction{} = transaction} = Transactions.deposit(valid_attrs)
      assert transaction.date == valid_attrs[:date]
      assert transaction.memo == valid_attrs[:memo]
      assert [%LineItem{} = line_item] = transaction.line_items
      assert line_item.amount == line_item_attrs[:amount]
    end

    test "associates the line_item to its fund", %{fund: fund} do
      valid_attrs = Factory.transaction_attrs(line_items: [Factory.line_item_attrs(fund)])

      {:ok, transaction} = Transactions.deposit(valid_attrs)
      [line_item] = transaction.line_items
      assert line_item.fund_id == fund.id
    end

    test "publishes a transaction created event", %{fund: fund} do
      valid_attrs = Factory.transaction_attrs(line_items: [Factory.line_item_attrs(fund)])

      :ok = PubSub.subscribe(Transactions.pubsub_topic())

      {:ok, transaction} = Transactions.deposit(valid_attrs)

      assert_received({:transaction_created, ^transaction})
    end

    test "requires at least one line item" do
      invalid_attrs = Factory.transaction_attrs(line_items: [])

      assert {:error, %Changeset{valid?: false} = changeset} = Transactions.deposit(invalid_attrs)
      assert hd(errors_on(changeset)[:line_items]) == "Requires at least one line item with a non-zero amount"
    end

    test "requires each line item to have a non-zero amount", %{fund: fund} do
      invalid_line_item_attrs = Factory.line_item_attrs(fund, amount: Money.zero(:usd))
      attrs = Factory.transaction_attrs(line_items: [invalid_line_item_attrs])

      assert {:error, %Changeset{valid?: false} = changeset} = Transactions.deposit(attrs)
      [line_item_errors] = errors_on(changeset)[:line_items]
      assert hd(line_item_errors[:amount]) == "must be not equal to $0.00"
    end

    test "returns error changeset for invalid transaction data" do
      invalid_attrs = Factory.transaction_attrs(date: nil, memo: nil)

      assert {:error, %Changeset{valid?: false}} = Transactions.deposit(invalid_attrs)
    end

    test "returns error changeset for invalid line item data", %{fund: fund} do
      invalid_line_item_attrs = Factory.line_item_attrs(fund, amount: "abc")
      attrs = Factory.transaction_attrs(line_items: [invalid_line_item_attrs])

      assert {:error, %Changeset{valid?: false}} = Transactions.deposit(attrs)
    end
  end

  describe "fetching a transaction" do
    test "when transaction exists, finds it by ID", %{fund: fund} do
      transaction = Factory.deposit(fund)

      assert {:ok, result} = Transactions.fetch_transaction(transaction.id)

      fields = Map.keys(transaction) -- [:total]
      assert_structs_equal(result, transaction, fields)
    end

    @tag capture_log: true
    test "when transaction does not exist, returns an error" do
      assert {:error, %NotFoundError{}} = Transactions.fetch_transaction(Factory.id())
    end
  end

  describe "listing transactions for a fund" do
    test "returns empty list if the fund has no transactions", %{fund: fund} do
      assert {[], %Paging{}} = Transactions.list_fund_transactions(fund)
    end

    test "returns a list of 'fund transactions' ordered descending by date", %{account: account, fund: fund} do
      deposits = for _i <- 1..3, do: Factory.deposit(fund)
      withdrawals = for _i <- 1..2, do: Factory.withdrawal(account, fund)

      expected = to_expected(deposits ++ withdrawals)

      assert {^expected, %Paging{}} = Transactions.list_fund_transactions(fund)
    end

    test "respects page size limit when specified", %{fund: fund} do
      transactions = for _i <- 1..5, do: Factory.deposit(fund)
      limit = 3

      expected = transactions |> to_expected() |> Enum.take(limit)

      assert {^expected, %Paging{}} = Transactions.list_fund_transactions(fund, per_page: limit)
    end

    test "pages forward", %{fund: fund} do
      transactions = for _i <- 1..5, do: Factory.deposit(fund)
      limit = 2
      [first, second, third] = transactions |> to_expected() |> Enum.chunk_every(limit)

      assert {^first, %Paging{next_cursor: next_cursor}} = Transactions.list_fund_transactions(fund, per_page: limit)

      assert {^second, %Paging{next_cursor: next_cursor}} =
               Transactions.list_fund_transactions(fund, next_cursor: next_cursor, per_page: limit)

      assert {^third, %Paging{next_cursor: nil}} =
               Transactions.list_fund_transactions(fund, next_cursor: next_cursor, per_page: limit)
    end

    test "pages backward", %{fund: fund} do
      transactions = for _i <- 1..5, do: Factory.deposit(fund)
      limit = 2
      [first, second, _third] = transactions |> to_expected() |> Enum.chunk_every(limit)

      {_list, %Paging{next_cursor: next_cursor}} = Transactions.list_fund_transactions(fund, per_page: limit)

      {_list, %Paging{next_cursor: next_cursor}} =
        Transactions.list_fund_transactions(fund, next_cursor: next_cursor, per_page: limit)

      {_list, %Paging{prev_cursor: prev_cursor}} =
        Transactions.list_fund_transactions(fund, next_cursor: next_cursor, per_page: limit)

      assert {^second, %Paging{prev_cursor: prev_cursor}} =
               Transactions.list_fund_transactions(fund, per_page: limit, prev_cursor: prev_cursor)

      assert {^first, %Paging{prev_cursor: nil}} =
               Transactions.list_fund_transactions(fund, per_page: limit, prev_cursor: prev_cursor)
    end

    defp to_expected(transactions) do
      transactions
      |> Enum.map(fn %Transaction{} = transaction ->
        [line_item] = transaction.line_items

        %FundTransaction{
          amount: line_item.amount,
          date: transaction.date,
          id: transaction.id,
          inserted_at: line_item.inserted_at,
          line_item_id: line_item.id,
          memo: transaction.memo,
          running_balance: Money.zero(:usd)
        }
      end)
      |> Enum.sort_by(& &1, {:desc, FundTransaction})
      |> Enum.reverse()
      |> Enum.reduce({[], Money.zero(:usd)}, fn txn, {result, balance} ->
        next_balance = Money.add!(balance, txn.amount)
        txn_with_balance = %{txn | running_balance: next_balance}
        {[txn_with_balance | result], next_balance}
      end)
      |> elem(0)
    end
  end

  describe "creating a changeset for a new transaction" do
    setup :create_funds

    test "defaults the date to today", %{funds: funds} do
      today = Timex.today(:local)
      %Changeset{} = changeset = Transactions.new_transaction(funds)

      assert Changeset.get_field(changeset, :date) == today
    end

    test "includes a line item for each fund", %{funds: funds} do
      [fund_id1, fund_id2, fund_id3] = Enum.map(funds, & &1.id)

      %Changeset{} = changeset = Transactions.new_transaction(funds)
      line_items = Changeset.get_assoc(changeset, :line_items, :struct)

      assert [
               %LineItem{fund_id: ^fund_id1},
               %LineItem{fund_id: ^fund_id2},
               %LineItem{fund_id: ^fund_id3}
             ] = line_items
    end

    test "computes an initial total for all line items", %{funds: funds} do
      %Changeset{} = changeset = Transactions.new_transaction(funds)
      assert Changeset.get_field(changeset, :total) == Money.zero(:usd)
    end
  end

  describe "making a regular deposit" do
    setup :create_funds

    test "creates a transaction and its line items with valid data", %{account: account, funds: funds} do
      date = Factory.date()

      assert {:ok, %Transaction{} = transaction} = Transactions.regular_deposit(account, date, funds)
      assert transaction.date == date
      assert transaction.memo == "Regular deposit"

      transaction.line_items
      |> Enum.zip(funds)
      |> Enum.each(fn {line_item, fund} ->
        amount = Funds.regular_deposit_amount(fund, account.deposits_per_year)
        fund_id = fund.id
        assert %LineItem{amount: ^amount, fund_id: ^fund_id} = line_item
      end)
    end

    test "omits funds with zero budgets", %{account: account, funds: original_funds} do
      zero_budget_fund = Factory.fund(account, budget: Money.zero(:usd))
      funds = [zero_budget_fund | original_funds]

      {:ok, %Transaction{} = transaction} = Transactions.regular_deposit(account, Factory.date(), funds)

      assert length(transaction.line_items) == length(original_funds)
      refute zero_budget_fund.id in Enum.map(transaction.line_items, & &1.fund_id)
    end

    test "publishes a transaction created event", %{account: account, funds: funds} do
      :ok = PubSub.subscribe(Transactions.pubsub_topic())

      {:ok, %Transaction{} = transaction} = Transactions.regular_deposit(account, Factory.date(), funds)

      assert_received({:transaction_created, ^transaction})
    end
  end

  describe "updating a single-fund transaction" do
    setup %{fund: fund} do
      transaction = Factory.deposit(fund)

      %{transaction: transaction}
    end

    test "with valid data updates the transaction", %{fund: fund, transaction: transaction} do
      [line_item] = transaction.line_items
      line_item_attrs = Factory.line_item_attrs(fund, id: line_item.id)
      valid_attrs = Factory.transaction_attrs(line_items: [line_item_attrs])

      assert {:ok, %Transaction{} = updated} = Transactions.update_transaction(transaction, valid_attrs)
      [updated_line_item] = updated.line_items
      assert updated.date == valid_attrs[:date]
      assert updated.memo == valid_attrs[:memo]
      assert updated_line_item.amount == line_item_attrs[:amount]
    end

    test "publishes a transaction updated event", %{fund: fund, transaction: transaction} do
      [line_item] = transaction.line_items
      line_item_attrs = Factory.line_item_attrs(fund, id: line_item.id)
      valid_attrs = Factory.transaction_attrs(line_items: [line_item_attrs])

      :ok = PubSub.subscribe(Transactions.pubsub_topic())

      {:ok, updated} = Transactions.update_transaction(transaction, valid_attrs)

      assert_received({:transaction_updated, ^updated})
    end

    test "with invalid data returns an error changeset", %{fund: fund, transaction: transaction} do
      [line_item] = transaction.line_items
      line_item_attrs = Factory.line_item_attrs(fund, amount: Money.zero(:usd), id: line_item.id)
      invalid_attrs = Factory.transaction_attrs(line_items: [line_item_attrs])

      expected = %{transaction | total: nil}

      assert {:error, %Changeset{valid?: false}} = Transactions.update_transaction(transaction, invalid_attrs)
      assert {:ok, expected} == Transactions.fetch_transaction(transaction.id)
    end
  end

  describe "making a withdrawal from a single fund" do
    setup %{fund: fund} do
      %{fund: Factory.with_balance(fund, ~M[5000]usd)}
    end

    test "creates a transaction and its line item with valid data", %{account: account, fund: fund} do
      line_item_attrs = Factory.line_item_attrs(fund)
      valid_attrs = Factory.transaction_attrs(line_items: [line_item_attrs])

      assert {:ok, %Transaction{} = transaction} = Transactions.withdraw(account, valid_attrs)
      assert transaction.date == valid_attrs[:date]
      assert transaction.memo == valid_attrs[:memo]
      assert [%LineItem{} = line_item] = transaction.line_items
      assert line_item.amount == MoneyUtils.negate(line_item_attrs[:amount])
    end

    test "associates the line_item to its fund", %{account: account, fund: fund} do
      valid_attrs = Factory.transaction_attrs(line_items: [Factory.line_item_attrs(fund)])

      {:ok, transaction} = Transactions.withdraw(account, valid_attrs)
      [line_item] = transaction.line_items
      assert line_item.fund_id == fund.id
    end

    test "publishes a transaction created event", %{account: account, fund: fund} do
      valid_attrs = Factory.transaction_attrs(line_items: [Factory.line_item_attrs(fund)])

      :ok = PubSub.subscribe(Transactions.pubsub_topic())

      {:ok, transaction} = Transactions.withdraw(account, valid_attrs)

      assert_received({:transaction_created, ^transaction})
    end

    test "covers overdraft from default fund", %{account: account, fund: fund} do
      default_fund = Factory.fund(account)
      account = Factory.with_default_fund(account, default_fund)
      overdraft = ~M[100]usd
      amount = Money.add!(fund.current_balance, overdraft)
      line_item_attrs = Factory.line_item_attrs(fund, amount: amount)
      valid_attrs = Factory.transaction_attrs(line_items: [line_item_attrs])

      assert {:ok, %Transaction{} = transaction} = Transactions.withdraw(account, valid_attrs)

      expected = [
        %LineItem{amount: MoneyUtils.negate(fund.current_balance), fund_id: fund.id},
        %LineItem{amount: MoneyUtils.negate(overdraft), fund_id: default_fund.id}
      ]

      assert_lists_equal(expected, transaction.line_items, &assert_structs_equal(&1, &2, [:amount, :fund_id]))
    end

    test "allows fund to go into overdraft if no default fund configured", %{account: account, fund: fund} do
      overdraft = ~M[100]usd
      amount = Money.add!(fund.current_balance, overdraft)
      line_item_attrs = Factory.line_item_attrs(fund, amount: amount)
      valid_attrs = Factory.transaction_attrs(line_items: [line_item_attrs])

      assert {:ok, %Transaction{} = transaction} = Transactions.withdraw(account, valid_attrs)

      assert [%LineItem{} = line_item] = transaction.line_items
      assert line_item.amount == MoneyUtils.negate(amount)
    end

    test "requires at least one line item", %{account: account} do
      invalid_attrs = Factory.transaction_attrs(line_items: [])

      assert {:error, %Changeset{valid?: false} = changeset} = Transactions.withdraw(account, invalid_attrs)
      assert hd(errors_on(changeset)[:line_items]) == "Requires at least one line item with a non-zero amount"
    end

    test "requires each line item to have a non-zero amount", %{account: account, fund: fund} do
      invalid_line_item_attrs = Factory.line_item_attrs(fund, amount: Money.zero(:usd))
      attrs = Factory.transaction_attrs(line_items: [invalid_line_item_attrs])

      assert {:error, %Changeset{valid?: false} = changeset} = Transactions.withdraw(account, attrs)
      [line_item_errors] = errors_on(changeset)[:line_items]
      assert hd(line_item_errors[:amount]) == "must be not equal to $0.00"
    end

    test "requires each line item to have a non-nil amount", %{account: account, fund: fund} do
      invalid_line_item_attrs = Factory.line_item_attrs(fund, amount: nil)
      attrs = Factory.transaction_attrs(line_items: [invalid_line_item_attrs])

      assert {:error, %Changeset{valid?: false} = changeset} = Transactions.withdraw(account, attrs)
      [line_item_errors] = errors_on(changeset)[:line_items]
      assert hd(line_item_errors[:amount]) == "can't be blank"
    end

    test "returns error changeset for invalid transaction data", %{account: account} do
      invalid_attrs = Factory.transaction_attrs(date: nil, memo: nil)

      assert {:error, %Changeset{valid?: false}} = Transactions.withdraw(account, invalid_attrs)
    end

    test "returns error changeset for invalid line item data", %{account: account, fund: fund} do
      invalid_line_item_attrs = Factory.line_item_attrs(fund, amount: "abc")
      attrs = Factory.transaction_attrs(line_items: [invalid_line_item_attrs])

      assert {:error, %Changeset{valid?: false}} = Transactions.withdraw(account, attrs)
    end

    test "error changeset un-negates the amount", %{account: account, fund: fund} do
      line_item_attrs = Factory.line_item_attrs(fund)
      attrs = Factory.transaction_attrs(date: nil, line_items: [line_item_attrs])

      assert {:error, %Changeset{action: :insert, valid?: false} = changeset} = Transactions.withdraw(account, attrs)
      [line_item] = Changeset.get_change(changeset, :line_items)
      assert Changeset.get_change(line_item, :amount) == line_item_attrs[:amount]
    end
  end

  describe "making a regular withdrawal" do
    setup :create_funds

    setup %{funds: funds} do
      funds = for fund <- funds, do: Factory.with_balance(fund, ~M[5000]usd)

      %{funds: funds}
    end

    test "creates a transaction and its line items with valid data", %{account: account, funds: funds} do
      line_item_attrs = Enum.map(funds, &Factory.line_item_attrs/1)
      valid_attrs = Factory.transaction_attrs(line_items: line_item_attrs)

      assert {:ok, %Transaction{} = transaction} = Transactions.withdraw(account, valid_attrs)
      assert transaction.date == valid_attrs[:date]
      assert transaction.memo == valid_attrs[:memo]

      transaction.line_items
      |> Enum.zip(line_item_attrs)
      |> Enum.each(fn {%LineItem{} = line_item, attrs} ->
        assert line_item.amount == MoneyUtils.negate(attrs[:amount])
      end)
    end

    test "associates each line_item to its fund", %{account: account, funds: funds} do
      line_item_attrs = Enum.map(funds, &Factory.line_item_attrs/1)
      valid_attrs = Factory.transaction_attrs(line_items: line_item_attrs)

      {:ok, transaction} = Transactions.withdraw(account, valid_attrs)

      transaction.line_items
      |> Enum.zip(funds)
      |> Enum.each(fn {%LineItem{} = line_item, %Fund{} = fund} ->
        assert line_item.fund_id == fund.id
      end)
    end

    test "publishes a transaction created event", %{account: account, funds: funds} do
      line_item_attrs = Enum.map(funds, &Factory.line_item_attrs/1)
      valid_attrs = Factory.transaction_attrs(line_items: line_item_attrs)

      :ok = PubSub.subscribe(Transactions.pubsub_topic())

      {:ok, transaction} = Transactions.withdraw(account, valid_attrs)

      assert_received({:transaction_created, ^transaction})
    end

    test "filters out null and zero amounts", %{account: account, funds: funds} do
      [fund1, fund2, fund3] = funds

      line_item_attrs = [
        Factory.line_item_attrs(fund1, amount: nil),
        Factory.line_item_attrs(fund2),
        Factory.line_item_attrs(fund3, amount: Money.zero(:usd))
      ]

      attrs = Factory.transaction_attrs(line_items: line_item_attrs)

      assert {:ok, transaction} = Transactions.withdraw(account, attrs)

      assert [%LineItem{} = line_item] = transaction.line_items
      assert line_item.fund_id == fund2.id
    end

    test "covers overdrafts from default fund", %{account: account, funds: funds} do
      default_fund = Factory.fund(account)
      account = Factory.with_default_fund(account, default_fund)
      overdraft1 = ~M[100]usd
      overdraft2 = ~M[50]usd

      [fund1, fund2, fund3] = funds

      line_item_attrs = [
        Factory.line_item_attrs(fund1, amount: Money.add!(fund1.current_balance, overdraft1)),
        Factory.line_item_attrs(fund2),
        Factory.line_item_attrs(fund3, amount: Money.add!(fund3.current_balance, overdraft2))
      ]

      valid_attrs = Factory.transaction_attrs(line_items: line_item_attrs)

      assert {:ok, %Transaction{} = transaction} = Transactions.withdraw(account, valid_attrs)

      overdraft_amount = Money.add!(overdraft1, overdraft2)
      line_item_attrs2 = Enum.at(line_item_attrs, 1)

      expected = [
        %LineItem{amount: MoneyUtils.negate(fund1.current_balance), fund_id: fund1.id},
        %LineItem{amount: MoneyUtils.negate(line_item_attrs2[:amount]), fund_id: fund2.id},
        %LineItem{amount: MoneyUtils.negate(fund3.current_balance), fund_id: fund3.id},
        %LineItem{amount: MoneyUtils.negate(overdraft_amount), fund_id: default_fund.id}
      ]

      assert_lists_equal(expected, transaction.line_items, &assert_structs_equal(&1, &2, [:amount, :fund_id]))
    end

    test "returns error changeset if no valid filtered line items", %{account: account, funds: funds} do
      line_item_attrs = Enum.map(funds, &Factory.line_item_attrs(&1, amount: nil))
      attrs = Factory.transaction_attrs(line_items: line_item_attrs)

      assert {:error, %Changeset{valid?: false} = changeset} = Transactions.withdraw(account, attrs)

      message = "Requires at least one line item with a non-zero amount"
      assert {^message, _opts} = changeset.errors[:line_items]
    end

    test "error changeset un-negates the amounts", %{account: account, funds: funds} do
      line_item_attrs = Enum.map(funds, &Factory.line_item_attrs/1)
      attrs = Factory.transaction_attrs(date: nil, line_items: line_item_attrs)

      assert {:error, %Changeset{action: :insert, valid?: false} = changeset} = Transactions.withdraw(account, attrs)

      changeset
      |> Changeset.get_change(:line_items)
      |> Enum.zip(line_item_attrs)
      |> Enum.each(fn {%Changeset{} = line_item, attrs} ->
        assert Changeset.get_change(line_item, :amount) == attrs[:amount]
      end)
    end
  end

  defp create_funds(%{account: account, fund: fund}) do
    fund2 = Factory.fund(account)
    fund3 = Factory.fund(account)
    %{funds: [fund, fund2, fund3]}
  end
end
