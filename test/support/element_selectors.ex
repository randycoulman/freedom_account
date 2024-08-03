defmodule FreedomAccountWeb.ElementSelectors do
  @moduledoc false

  @type selector :: String.t()

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

  @spec fund_subtitle :: selector()
  def fund_subtitle, do: "#fund-subtitle"

  @spec heading :: selector()
  def heading, do: "h2"

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

  @spec table_cell :: selector()
  def table_cell, do: "td"

  @spec title :: selector()
  def title, do: "h1"
end
