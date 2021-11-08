defmodule FreedomAccount.Schema do
  @moduledoc """
  Common settings for all Ecto schemas.

  See `Ecto.Schema`.
  """

  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema

      import unquote(__MODULE__)

      @primary_key {:id, :binary_id, autogenerate: true}
      @timestamps_opts [type: :utc_datetime]
    end
  end
end
