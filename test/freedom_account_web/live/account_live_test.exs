defmodule FreedomAccountWeb.AccountLiveTest do
  use FreedomAccountWeb.ConnCase, async: true

  alias FreedomAccount.Factory
  alias Phoenix.HTML.Safe

  describe "Edit" do
    setup :create_account

    test "updates account settings", %{conn: conn} do
      %{deposits_per_year: deposits, name: name} = Factory.account_attrs()

      conn
      |> visit(~p"/account/edit")
      |> assert_has(page_title(), text: "Edit Account Settings")
      |> assert_has(heading(), text: "Edit Account Settings")
      |> fill_in("Name", with: "")
      |> fill_in("Deposits / year", with: "")
      |> assert_has(field_error("#account_name"), text: "can't be blank")
      |> assert_has(field_error("#account_deposits_per_year"), text: "can't be blank")
      |> fill_in("Name", with: name)
      |> fill_in("Deposits / year", with: deposits)
      |> click_button("Save Account")
      |> assert_has(flash(:info), text: "Account updated successfully")
      |> assert_has(heading(), text: name)
    end

    test "selects default fund", %{account: account, conn: conn} do
      funds = for _i <- 1..5, do: Factory.fund(account)
      default_fund = Enum.random(funds)

      conn
      |> visit(~p"/account/edit")
      |> select("Default fund", option: Safe.to_iodata(default_fund))
      |> click_button("Save Account")
      |> assert_has(flash(:info), text: "Account updated successfully")
      |> visit(~p"/account/edit")
      |> assert_has(selected_option("#default-fund"), text: Safe.to_iodata(default_fund))
    end

    test "does not update account settings on cancel", %{account: account, conn: conn} do
      %{deposits_per_year: deposits, name: name} = Factory.account_attrs()

      conn
      |> visit(~p"/account/edit")
      |> fill_in("Name", with: name)
      |> fill_in("Deposits / year", with: deposits)
      |> click_link("Cancel")
      |> assert_has(heading(), text: account.name)
    end

    test "returns to fund list by default on save", %{conn: conn} do
      conn
      |> visit(~p"/account/edit")
      |> click_button("Save Account")
      |> assert_has(active_tab(), text: "Funds")
    end

    test "returns to fund list by default on cancel", %{conn: conn} do
      conn
      |> visit(~p"/account/edit")
      |> click_link("Cancel")
      |> assert_has(active_tab(), text: "Funds")
    end

    for {return_to, tab_title} <- [
          {"funds", "Funds"},
          {"loans", "Loans"},
          {"transactions", "Transactions"}
        ] do
      test "returns to #{return_to} list when specified on save", %{conn: conn} do
        return_to = unquote(return_to)
        tab_title = unquote(tab_title)

        params = %{return_to: return_to}

        conn
        |> visit(~p"/account/edit?#{params}")
        |> click_button("Save Account")
        |> assert_has(active_tab(), text: tab_title)
      end

      test "returns to #{return_to} list when specified on cancel", %{conn: conn} do
        return_to = unquote(return_to)
        tab_title = unquote(tab_title)

        params = %{return_to: return_to}

        conn
        |> visit(~p"/account/edit?#{params}")
        |> click_link("Cancel")
        |> assert_has(active_tab(), text: tab_title)
      end
    end
  end
end
