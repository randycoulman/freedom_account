defmodule FreedomAccountWeb.Schema.UserTypes do
  @moduledoc """
  GraphQL type definitions for users.
  """

  use Absinthe.Schema.Notation

  @desc "A user"
  object :user do
    @desc "The user's unique ID"
    field :id, non_null(:id)
    @desc "The name of the user"
    field :name, non_null(:string)
  end
end
