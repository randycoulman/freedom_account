defmodule FreedomAccountWeb.ElementSelectors do
  @moduledoc false
  alias FreedomAccount.Funds.Fund

  @type selector :: String.t()

  @spec account_balance :: selector()
  def account_balance, do: testid("account-balance")

  @spec action_link(selector()) :: selector()
  def action_link(selector), do: "#{selector} a"

  @spec active_tab :: selector()
  def active_tab, do: "li[data-active=true]"

  @spec disabled(selector()) :: selector()
  def disabled(selector), do: "#{selector}[disabled]"

  @spec enabled(selector()) :: selector()
  def enabled(selector), do: "#{selector}:not([disabled])"

  @spec field_error(selector()) :: selector()
  def field_error(selector), do: "#{selector} ~ [name='error']"

  @spec field_value(selector(), String.t()) :: selector()
  def field_value(selector, value), do: "#{selector}[value='#{value}']"

  @spec flash(atom()) :: selector()
  def flash(level), do: "#flash-#{level}"

  @spec fund_action(Fund.t()) :: selector()
  def fund_action(%Fund{} = fund) do
    fund |> fund_card() |> action_link()
  end

  @spec fund_balance(Fund.t() | :any_card) :: selector()
  def fund_balance(fund \\ :any_card) do
    fund_field(fund, "balance")
  end

  @spec fund_budget(Fund.t() | :any_card) :: selector()
  def fund_budget(fund \\ :any_card) do
    fund_field(fund, "budget")
  end

  @spec fund_card(Fund.t() | :any_card) :: selector()
  def fund_card(:any_card), do: testid("fund-card")
  def fund_card(%Fund{} = fund), do: "#funds-#{fund.id}"

  @spec fund_frequency(Fund.t() | :any_card) :: selector()
  def fund_frequency(fund \\ :any_card) do
    fund_budget(fund)
  end

  @spec fund_icon(Fund.t() | :any_card) :: selector()
  def fund_icon(fund \\ :any_card) do
    fund_field(fund, "icon")
  end

  @spec fund_name :: selector()
  @spec fund_name(Fund.t() | :any_card) :: selector()
  def fund_name(fund \\ :any_card) do
    fund_field(fund, "name")
  end

  @spec fund_subtitle :: selector()
  def fund_subtitle, do: "#fund-subtitle"

  @spec heading :: selector()
  def heading, do: "h2"

  @spec heading_link :: selector()
  def heading_link, do: "#{heading()} #{link()}"

  @spec inactive_tab :: selector()
  def inactive_tab, do: "li[data-active=false]"

  @spec link :: selector()
  def link, do: "a"

  @spec page_title :: selector()
  def page_title, do: "title"

  @spec role(String.t()) :: selector()
  def role(role), do: "[data-role=#{role}]"

  @spec selected_option(selector()) :: selector()
  def selected_option(selector), do: "#{selector} option[selected='selected']"

  @spec sidebar_fund_balance :: selector()
  def sidebar_fund_balance, do: "#{sidebar_fund_name()} ~ span"

  @spec sidebar_fund_name :: selector()
  def sidebar_fund_name, do: "aside nav a"

  @spec sidebar_loan_balance :: selector()
  def sidebar_loan_balance, do: "#{sidebar_loan_name()} ~ span"

  @spec sidebar_loan_name :: selector()
  def sidebar_loan_name, do: "aside nav a"

  @spec table_cell :: selector()
  def table_cell, do: "td"

  @spec testid(String.t()) :: selector()
  def testid(test_id), do: ~s'[data-testid="#{test_id}"]'

  @spec title :: selector()
  def title, do: "h1"

  defp fund_field(fund_or_any, testid) do
    "#{fund_card(fund_or_any)} #{testid(testid)}"
  end
end
