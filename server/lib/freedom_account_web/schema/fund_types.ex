defmodule FreedomAccountWeb.Schema.FundTypes do
  @moduledoc """
  GraphQL type definitions for funds.
  """

  use Absinthe.Schema.Notation

  @desc "A savings fund"
  object :fund do
    @desc "An icon for the fund (in the form of an emoji)"
    field :icon, non_null(:string)
    @desc "The fund's unique identifier"
    field :id, non_null(:id)
    @desc "The name of the fund"
    field :name, non_null(:string)
  end

  @desc "Fund settings input"
  input_object :fund_input do
    @desc "An icon for the fund (in the form of an emoji)"
    field :icon, non_null(:string)
    @desc "The fund's unique identifier"
    field :id, :id
    @desc "The name of the fund"
    field :name, non_null(:string)
  end
end
