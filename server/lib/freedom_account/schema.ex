defmodule FreedomAccount.Schema do
  @moduledoc """
  Common settings for all Ecto schemas.

  See `Ecto.Schema`.
  """

  alias Ecto.Schema

  @type belongs_to(t) :: Schema.belongs_to(t)
  @type has_many(t) :: Schema.has_many(t)
  @type id :: Ecto.UUID.t()
  @type t :: Schema.t()

  defmacro __using__(_opts) do
    quote do
      import Ecto.Changeset

      use Ecto.Schema

      import unquote(__MODULE__)

      @primary_key {:id, :binary_id, autogenerate: true}
      @timestamps_opts [type: :utc_datetime]
    end
  end
end
