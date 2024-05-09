defmodule FreedomAccount.TransactionsTest do
  use FreedomAccount.DataCase, async: true

  import Money.Sigil

  alias Ecto.Changeset
  alias FreedomAccount.Factory
  alias FreedomAccount.Transactions
  alias FreedomAccount.Transactions.LineItem
  alias FreedomAccount.Transactions.Transaction

  setup [:create_account, :create_fund]

  describe "creating a changeset for a Transaction" do
    test "returns the changeset", %{} do
      assert %Changeset{} = Transactions.change_transaction(%Transaction{})
    end

    test "defaults the date to today" do
      changeset = Transactions.change_transaction(%Transaction{})
      assert Changeset.get_change(changeset, :date) == Timex.today(:local)
    end
  end

  describe "making a deposit to a single fund" do
    test "creates a transaction and its line item with valid data", %{fund: fund} do
      line_item_attrs = Factory.line_item_attrs(fund)
      valid_attrs = Factory.transaction_attrs(line_items: [line_item_attrs])

      assert {:ok, %Transaction{} = transaction} = Transactions.deposit(valid_attrs)
      assert transaction.date == valid_attrs[:date]
      assert transaction.description == valid_attrs[:description]
      assert [%LineItem{} = line_item] = transaction.line_items
      assert line_item.amount == line_item_attrs[:amount]
    end

    test "associates the line_item to its fund", %{fund: fund} do
      valid_attrs = Factory.transaction_attrs(line_items: [Factory.line_item_attrs(fund)])

      {:ok, transaction} = Transactions.deposit(valid_attrs)
      [line_item] = transaction.line_items
      assert line_item.fund_id == fund.id
    end

    test "requires at least one line item" do
      invalid_attrs = Factory.transaction_attrs(line_items: [])

      assert {:error, %Changeset{valid?: false} = changeset} = Transactions.deposit(invalid_attrs)
      assert hd(errors_on(changeset)[:line_items]) == "can't be blank"
    end

    test "requires each line item to have a non-zero amount", %{fund: fund} do
      invalid_line_item_attrs = Factory.line_item_attrs(fund, amount: ~M[0]usd)
      attrs = Factory.transaction_attrs(line_items: [invalid_line_item_attrs])

      assert {:error, %Changeset{valid?: false} = changeset} = Transactions.deposit(attrs)
      [line_item_errors] = errors_on(changeset)[:line_items]
      assert hd(line_item_errors[:amount]) == "must be not equal to $0.00"
    end

    test "returns error changeset for invalid transaction data" do
      invalid_attrs = Factory.transaction_attrs(date: nil, description: nil)

      assert {:error, %Changeset{valid?: false}} = Transactions.deposit(invalid_attrs)
    end

    test "returns error changeset for invalid line item data", %{fund: fund} do
      invalid_line_item_attrs = Factory.line_item_attrs(fund, amount: "abc")
      attrs = Factory.transaction_attrs(line_items: [invalid_line_item_attrs])

      assert {:error, %Changeset{valid?: false}} = Transactions.deposit(attrs)
    end
  end

  describe "creating a new single-fund deposit transaction" do
    test "includes a single line item for the given fund", %{fund: fund} do
      fund_id = fund.id

      assert %Transaction{
               line_items: [%LineItem{fund_id: ^fund_id}]
             } = Transactions.new_deposit(fund)
    end
  end
end
