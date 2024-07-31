defmodule FreedomAccount.LoansTest do
  @moduledoc false

  use FreedomAccount.DataCase, async: true

  # import Assertions
  # import Money.Sigil

  alias Ecto.Changeset
  # alias FreedomAccount.Error.NotAllowedError
  alias FreedomAccount.Error.NotFoundError
  alias FreedomAccount.Factory
  alias FreedomAccount.Loans
  alias FreedomAccount.Loans.Loan
  # alias FreedomAccount.MoneyUtils
  alias FreedomAccount.PubSub

  @moduletag capture_log: true

  @invalid_attrs %{icon: nil, name: nil}

  setup [:create_account]

  # describe "creating a changeset for activating/deactivating loans" do
  #   test "returns a changeset for all inactive loans plus active loans with a zero balance", %{account: account} do
  #     _loans = [
  #       Factory.loan(account, name: "Can Deactivate", current_balance: Money.zero(:usd)),
  #       Factory.inactive_loan(account, name: "Inactive", current_balance: Money.zero(:usd)),
  #       account |> Factory.loan(name: "Has Non-Zero Balance") |> Factory.with_loan_balance(~M[-150]usd),
  #       Factory.loan(account, name: "To Deactivate", current_balance: Money.zero(:usd))
  #     ]

  #     assert %Changeset{} = changeset = Loans.change_activation(account)
  #     embedded_loans = Changeset.get_embed(changeset, :loans)

  #     names = Enum.map(embedded_loans, &Changeset.get_field(&1, :name))

  #     assert_lists_equal(names, ["Can Deactivate", "Inactive", "To Deactivate"])
  #   end
  # end

  describe "creating a changeset for a loan" do
    test "returns the changeset", %{account: account} do
      loan = Factory.loan(account)
      assert %Changeset{} = Loans.change_loan(loan)
    end
  end

  describe "creating a loan" do
    test "creates a loan with valid data", %{account: account} do
      valid_attrs = Factory.loan_attrs()

      assert {:ok, %Loan{} = loan} = Loans.create_loan(account, valid_attrs)
      assert loan.icon == valid_attrs[:icon]
      assert loan.name == valid_attrs[:name]
    end

    test "associates the loan to its account", %{account: account} do
      valid_attrs = Factory.loan_attrs()

      {:ok, loan} = Loans.create_loan(account, valid_attrs)
      assert loan.account_id == account.id
    end

    test "marks the loan as active", %{account: account} do
      valid_attrs = Factory.loan_attrs()

      {:ok, loan} = Loans.create_loan(account, valid_attrs)
      assert loan.active
    end

    test "publishes a loan created event", %{account: account} do
      valid_attrs = Factory.loan_attrs()

      :ok = PubSub.subscribe(Loans.pubsub_topic())

      {:ok, loan} = Loans.create_loan(account, valid_attrs)

      assert_received({:loan_created, ^loan})
    end

    test "returns error changeset for invalid data", %{account: account} do
      assert {:error, %Changeset{valid?: false}} = Loans.create_loan(account, @invalid_attrs)
    end
  end

  describe "deactivating a loan" do
    test "marks the loan as inactive", %{account: account} do
      loan = Factory.loan(account, current_balance: Money.zero(:usd))

      assert {:ok, %Loan{} = updated_loan} = Loans.deactivate_loan(loan)

      refute updated_loan.active
    end

    # test "returns error if loan cannot be deactivated", %{account: account} do
    #   loan = account |> Factory.loan() |> Factory.with_loan_balance()

    #   assert {:error, %NotAllowedError{}} = Loans.deactivate_loan(loan)
    # end
  end

  describe "deleting a loan" do
    setup :create_loan

    test "deletes the loan", %{account: account, loan: loan} do
      assert :ok = Loans.delete_loan(loan)
      assert {:error, %NotFoundError{}} = Loans.fetch_active_loan(account, loan.id)
    end

    test "publishes a loan deleted event", %{loan: loan} do
      loan_id = loan.id
      :ok = PubSub.subscribe(Loans.pubsub_topic())

      :ok = Loans.delete_loan(loan)

      assert_received({:loan_deleted, %Loan{id: ^loan_id}})
    end

    # @tag capture_log: true
    # test "disallows deleting a loan with transactions", %{loan: loan} do
    #   Factory.lend(loan)
    #   assert {:error, %NotAllowedError{}} = Loans.delete_loan(loan)
    # end
  end

  describe "fetching a loan" do
    test "when loan exists for the provided account, finds the loan by ID", %{account: account} do
      loan = Factory.loan(account)
      assert {:ok, loan} == Loans.fetch_active_loan(account, loan.id)
    end

    test "when loan is inactive, returns an error", %{account: account} do
      loan = Factory.inactive_loan(account)
      assert {:error, %NotFoundError{}} = Loans.fetch_active_loan(account, loan.id)
    end

    test "when loan exists, but for a different account, returns an error", %{account: account} do
      other_account = Factory.account()
      loan = Factory.loan(other_account)

      assert {:error, %NotFoundError{}} = Loans.fetch_active_loan(account, loan.id)
    end

    test "when loan does not exist, returns an error", %{account: account} do
      assert {:error, %NotFoundError{}} = Loans.fetch_active_loan(account, Factory.id())
    end
  end

  # describe "listing active loans" do
  #   setup %{account: account} do
  #     loans = for _i <- 1..3, do: Factory.loan(account, current_balance: Money.zero(:usd))

  #     %{loans: loans}
  #   end

  #   test "returns all active loans sorted by name", %{account: account, loans: loans} do
  #     sorted_loans = Enum.sort_by(loans, & &1.name)
  #     assert Loans.list_active_loans(account) == sorted_loans
  #   end

  #   test "includes current balance of each loan", %{account: account, loans: loans} do
  #     calculate_amount = &Money.mult!(~M[10.00]usd, &1.id)

  #     # Enum.each(loans, fn loan ->
  #     #   Factory.lend(loan, amount: calculate_amount.(loan))
  #     # end)

  #     account
  #     |> Loans.list_active_loans()
  #     |> Enum.each(fn loan ->
  #       assert loan.current_balance == calculate_amount.(loan)
  #     end)
  #   end

  #   test "filters by a list of ids when provided", %{account: account, loans: loans} do
  #     [loan1, _loan2, loan3] = loans

  #     result = Loans.list_active_loans(account, [loan1.id, loan3.id])

  #     fields = Map.keys(loan1) -- [:current_balance]
  #     assert_lists_equal(result, [loan1, loan3], &assert_maps_equal(&1, &2, fields))
  #   end

  #   test "does not include inactive loans", %{account: account, loans: active_loans} do
  #     _inactive_loan = Factory.inactive_loan(account)

  #     assert_lists_equal(Loans.list_active_loans(account), active_loans)
  #   end
  # end

  # describe "listing all loans" do
  #   setup %{account: account} do
  #     loans = for _i <- 1..3, do: Factory.loan(account, current_balance: Money.zero(:usd))

  #     %{loans: [Factory.inactive_loan(account, current_balance: Money.zero(:usd)) | loans]}
  #   end

  #   test "returns all loans (both active and inactive) sorted by name", %{account: account, loans: loans} do
  #     sorted_loans = Enum.sort_by(loans, & &1.name)
  #     assert Loans.list_all_loans(account) == sorted_loans
  #   end

  #   test "includes current balance of each loan", %{account: account, loans: loans} do
  #     calculate_amount = &Money.mult!(~M[10.00]usd, &1.id)

  #     # Enum.each(loans, fn loan ->
  #     #   Factory.lend(loan, amount: calculate_amount.(loan))
  #     # end)

  #     account
  #     |> Loans.list_all_loans()
  #     |> Enum.each(fn loan ->
  #       assert loan.current_balance == calculate_amount.(loan)
  #     end)
  #   end
  # end

  # describe "updating loan activation" do
  #   test "saves active flag for all loans", %{account: account} do
  #     loans = [
  #       Factory.loan(account),
  #       Factory.inactive_loan(account),
  #       Factory.loan(account)
  #     ]

  #     valid_attrs = Factory.loans_activation_attrs(loans)

  #     assert {:ok, updated_loans} = Loans.update_activation(account, valid_attrs)

  #     valid_attrs.loans
  #     |> Enum.zip(updated_loans)
  #     |> Enum.each(fn {{_index, attrs}, loan} ->
  #       assert loan.active == attrs[:active]
  #     end)
  #   end

  #   test "publishes an activation updated event", %{account: account} do
  #     loans = [
  #       Factory.loan(account),
  #       Factory.inactive_loan(account),
  #       Factory.loan(account)
  #     ]

  #     valid_attrs = Factory.budget_attrs(loans)

  #     :ok = PubSub.subscribe(Loans.pubsub_topic())

  #     {:ok, updated_loans} = Loans.update_activation(account, valid_attrs)

  #     assert_received({:activation_updated, ^updated_loans})
  #   end

  #   test "with invalid data returns an error changeset", %{account: account} do
  #     loans = [
  #       Factory.loan(account, current_balance: Money.zero(:usd)),
  #       Factory.inactive_loan(account, current_balance: Money.zero(:usd))
  #     ]

  #     invalid_attrs =
  #       loans
  #       |> Factory.loans_activation_attrs()
  #       |> update_in([:loans, "1"], &Map.put(&1, :active, nil))

  #     assert {:error, %Changeset{valid?: false} = changeset} = Loans.update_activation(account, invalid_attrs)
  #     assert [%Changeset{valid?: true}, %Changeset{valid?: false}] = Changeset.get_embed(changeset, :loans)
  #     assert_lists_equal(loans, Loans.list_all_loans(account))
  #   end
  # end

  describe "updating a loan" do
    setup :create_loan

    test "with valid data updates the loan", %{loan: loan} do
      valid_attrs = Factory.loan_attrs()

      assert {:ok, %Loan{} = loan} = Loans.update_loan(loan, valid_attrs)
      assert loan.icon == valid_attrs[:icon]
      assert loan.name == valid_attrs[:name]
    end

    test "publishes a loan updated event", %{loan: loan} do
      valid_attrs = Factory.loan_attrs()

      :ok = PubSub.subscribe(Loans.pubsub_topic())

      {:ok, updated_loan} = Loans.update_loan(loan, valid_attrs)

      assert_received({:loan_updated, ^updated_loan})
    end

    test "with invalid data returns an error changeset", %{account: account, loan: loan} do
      assert {:error, %Changeset{valid?: false}} = Loans.update_loan(loan, @invalid_attrs)
      assert {:ok, loan} == Loans.fetch_active_loan(account, loan.id)
    end

    test "does not allow associating with a different account", %{account: original_account, loan: loan} do
      other_account = Factory.account()
      valid_attrs = Factory.loan_attrs(account_id: other_account.id)

      assert {:ok, %Loan{} = loan} = Loans.update_loan(loan, valid_attrs)
      assert loan.account_id == original_account.id
    end
  end

  # describe "updating a loan's balance" do
  #   setup :create_loan

  #   test "returns the loan with it's latest current balance", %{loan: loan} do
  #     amount = MoneyUtils.negate(Factory.money())
  #     # Factory.lend(loan, amount: amount)

  #     assert {:ok, %Loan{current_balance: ^amount}} = Loans.with_updated_balance(loan)
  #   end
  # end
end
