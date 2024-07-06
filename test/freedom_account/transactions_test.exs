defmodule FreedomAccount.TransactionsTest do
  use FreedomAccount.DataCase, async: true

  import Money.Sigil

  alias Ecto.Changeset
  alias FreedomAccount.Factory
  alias FreedomAccount.Funds
  alias FreedomAccount.PubSub
  alias FreedomAccount.Transactions
  alias FreedomAccount.Transactions.LineItem
  alias FreedomAccount.Transactions.Transaction

  setup [:create_account, :create_fund]

  describe "creating a changeset for a Transaction" do
    test "returns the changeset", %{} do
      assert %Changeset{} = Transactions.change_transaction(%Transaction{})
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

      PubSub.subscribe(Transactions.pubsub_topic())

      {:ok, transaction} = Transactions.deposit(valid_attrs)

      assert_received({:transaction_created, ^transaction})
    end

    test "requires at least one line item" do
      invalid_attrs = Factory.transaction_attrs(line_items: [])

      assert {:error, %Changeset{valid?: false} = changeset} = Transactions.deposit(invalid_attrs)
      assert hd(errors_on(changeset)[:line_items]) == "can't be blank"
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

  describe "creating a new deposit changeset" do
    test "defaults the date to today", %{fund: fund} do
      today = Timex.today(:local)

      %Changeset{} = changeset = Transactions.new_deposit(fund)

      assert Changeset.get_field(changeset, :date) == today
    end

    test "includes a single line item for the given fund", %{fund: fund} do
      fund_id = fund.id

      %Changeset{} = changeset = Transactions.new_deposit(fund)
      line_items = Changeset.get_assoc(changeset, :line_items, :struct)

      assert [%LineItem{fund_id: ^fund_id}] = line_items
    end
  end

  describe "creating a regular withdrawal changeset" do
    setup :create_funds

    test "defaults the date to today", %{funds: funds} do
      today = Timex.today(:local)
      %Changeset{} = changeset = Transactions.new_regular_withdrawal(funds)

      assert Changeset.get_field(changeset, :date) == today
    end

    test "includes a line item for each fund", %{funds: funds} do
      [fund_id1, fund_id2, fund_id3] = Enum.map(funds, & &1.id)

      %Changeset{} = changeset = Transactions.new_regular_withdrawal(funds)
      line_items = Changeset.get_assoc(changeset, :line_items, :struct)

      assert [
               %LineItem{fund_id: ^fund_id1},
               %LineItem{fund_id: ^fund_id2},
               %LineItem{fund_id: ^fund_id3}
             ] = line_items
    end
  end

  describe "creating a new single-fund transaction" do
    test "defaults the date to today", %{fund: fund} do
      today = Timex.today(:local)

      assert %Transaction{
               date: ^today
             } = Transactions.new_single_fund_transaction(fund)
    end

    test "includes a single line item for the given fund", %{fund: fund} do
      fund_id = fund.id

      assert %Transaction{
               line_items: [%LineItem{fund_id: ^fund_id}]
             } = Transactions.new_single_fund_transaction(fund)
    end
  end

  describe "making a regular deposit" do
    setup :create_funds

    test "creates a transaction and its line items with valid data", %{funds: funds} do
      deposits_per_year = Factory.deposit_count()
      date = Factory.date()

      assert {:ok, %Transaction{} = transaction} = Transactions.regular_deposit(date, funds, deposits_per_year)
      assert transaction.date == date
      assert transaction.memo == "Regular deposit"

      transaction.line_items
      |> Enum.zip(funds)
      |> Enum.each(fn {line_item, fund} ->
        amount = Funds.regular_deposit_amount(fund, deposits_per_year)
        fund_id = fund.id
        assert %LineItem{amount: ^amount, fund_id: ^fund_id} = line_item
      end)
    end

    test "omits funds with zero budgets", %{account: account, funds: original_funds} do
      zero_budget_fund = Factory.fund(account, budget: Money.zero(:usd))
      funds = [zero_budget_fund | original_funds]

      {:ok, %Transaction{} = transaction} = Transactions.regular_deposit(Factory.date(), funds, Factory.deposit_count())

      assert length(transaction.line_items) == length(original_funds)
      refute zero_budget_fund.id in Enum.map(transaction.line_items, & &1.fund_id)
    end

    test "publishes a transaction created event", %{funds: funds} do
      PubSub.subscribe(Transactions.pubsub_topic())

      {:ok, %Transaction{} = transaction} = Transactions.regular_deposit(Factory.date(), funds, Factory.deposit_count())

      assert_received({:transaction_created, ^transaction})
    end
  end

  describe "making a withdrawal from a single fund" do
    setup %{fund: fund} do
      Factory.deposit(fund, amount: ~M[5000]usd)
      :ok
    end

    test "creates a transaction and its line item with valid data", %{fund: fund} do
      line_item_attrs = Factory.line_item_attrs(fund)
      valid_attrs = Factory.transaction_attrs(line_items: [line_item_attrs])

      assert {:ok, %Transaction{} = transaction} = Transactions.withdraw(valid_attrs)
      assert transaction.date == valid_attrs[:date]
      assert transaction.memo == valid_attrs[:memo]
      assert [%LineItem{} = line_item] = transaction.line_items
      assert line_item.amount == Money.mult!(line_item_attrs[:amount], -1)
    end

    test "associates the line_item to its fund", %{fund: fund} do
      valid_attrs = Factory.transaction_attrs(line_items: [Factory.line_item_attrs(fund)])

      {:ok, transaction} = Transactions.withdraw(valid_attrs)
      [line_item] = transaction.line_items
      assert line_item.fund_id == fund.id
    end

    test "publishes a transaction created event", %{fund: fund} do
      valid_attrs = Factory.transaction_attrs(line_items: [Factory.line_item_attrs(fund)])

      PubSub.subscribe(Transactions.pubsub_topic())

      {:ok, transaction} = Transactions.withdraw(valid_attrs)

      assert_received({:transaction_created, ^transaction})
    end

    test "requires at least one line item" do
      invalid_attrs = Factory.transaction_attrs(line_items: [])

      assert {:error, %Changeset{valid?: false} = changeset} = Transactions.withdraw(invalid_attrs)
      assert hd(errors_on(changeset)[:line_items]) == "can't be blank"
    end

    test "requires each line item to have a non-zero amount", %{fund: fund} do
      invalid_line_item_attrs = Factory.line_item_attrs(fund, amount: Money.zero(:usd))
      attrs = Factory.transaction_attrs(line_items: [invalid_line_item_attrs])

      assert {:error, %Changeset{valid?: false} = changeset} = Transactions.withdraw(attrs)
      [line_item_errors] = errors_on(changeset)[:line_items]
      assert hd(line_item_errors[:amount]) == "must be not equal to $0.00"
    end

    test "returns error changeset for invalid transaction data" do
      invalid_attrs = Factory.transaction_attrs(date: nil, memo: nil)

      assert {:error, %Changeset{valid?: false}} = Transactions.withdraw(invalid_attrs)
    end

    test "returns error changeset for invalid line item data", %{fund: fund} do
      invalid_line_item_attrs = Factory.line_item_attrs(fund, amount: "abc")
      attrs = Factory.transaction_attrs(line_items: [invalid_line_item_attrs])

      assert {:error, %Changeset{valid?: false}} = Transactions.withdraw(attrs)
    end

    test "error changeset un-negates the amount", %{fund: fund} do
      line_item_attrs = Factory.line_item_attrs(fund)
      attrs = Factory.transaction_attrs(date: nil, line_items: [line_item_attrs])

      assert {:error, %Changeset{action: :insert, valid?: false} = changeset} = Transactions.withdraw(attrs)
      [line_item] = Changeset.get_change(changeset, :line_items)
      assert Changeset.get_change(line_item, :amount) == line_item_attrs[:amount]
    end
  end

  defp create_funds(%{account: account, fund: fund}) do
    fund2 = Factory.fund(account)
    fund3 = Factory.fund(account)
    %{funds: [fund, fund2, fund3]}
  end
end
