defmodule FreedomAccountWeb.Schema.FundTypes do
  @moduledoc """
  GraphQL type definitions for funds.
  """

  use Absinthe.Schema.Notation

  @desc "A savings fund"
  object :fund do
    field :icon, non_null(:string), description: "An icon for the fund (in the form of an emoji)"
    field :id, non_null(:id), description: "The fund's unique identifier"
    field :name, non_null(:string), description: "The name of the fund"
  end
end
