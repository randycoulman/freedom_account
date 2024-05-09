defmodule FreedomAccountWeb.ElementSelectors do
  @moduledoc false

  @type selector :: String.t()

  @spec action_link(selector()) :: selector()
  def action_link(selector), do: "#{selector} a"

  @spec field_error(selector()) :: selector()
  def field_error(selector), do: "#{selector} ~ [name='error']"

  @spec field_value(selector(), String.t()) :: selector()
  def field_value(selector, value), do: "#{selector}[value='#{value}']"

  @spec flash(atom()) :: selector()
  def flash(level), do: "#flash-#{level}"

  @spec heading :: selector()
  def heading, do: "h2"

  @spec link :: selector()
  def link, do: "a"

  @spec page_title :: selector()
  def page_title, do: "title"

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
