defmodule FreedomAccount.Error do
  @moduledoc """
  Definitions and constructors for application-specific errors.

  All errors from outside of the application should be mapped to a
  `FreedomAccount.Error` when first encountered.
  """
  require Logger

  defmodule InvariantError do
    @moduledoc false
    @enforce_keys [:message]
    defexception [:message]

    @type t :: %__MODULE__{
            message: String.t()
          }
  end

  defmodule NotAllowedError do
    @moduledoc false
    @enforce_keys [:message]
    defexception [:message]

    @type t :: %__MODULE__{
            message: String.t()
          }
  end

  defmodule NotFoundError do
    @moduledoc false
    @enforce_keys [:entity]
    defexception details: %{}, entity: nil

    @type t :: %__MODULE__{
            details: map(),
            entity: atom()
          }

    @impl Exception
    def message(%__MODULE__{} = error) do
      "Could not find #{humanize(error.entity)}"
    end

    defp humanize(entity) do
      entity |> Module.split() |> List.last() |> String.downcase()
    rescue
      ArgumentError ->
        entity |> to_string() |> String.downcase()
    end
  end

  defmodule ServiceError do
    @moduledoc false
    @enforce_keys [:message, :service]
    defexception [:message, :service]

    @type t :: %__MODULE__{
            message: String.t(),
            service: atom()
          }

    @impl Exception
    def message(%__MODULE__{} = error) do
      "[#{error.service}] #{error.message}"
    end
  end

  @type t ::
          InvariantError.t()
          | NotAllowedError.t()
          | NotFoundError.t()
          | ServiceError.t()

  @spec invariant([opt]) :: InvariantError.t()
        when opt: {:message, String.t()}
  def invariant(opts), do: InvariantError.exception(opts)

  @spec not_allowed([opt]) :: NotAllowedError.t()
        when opt: {:message, String.t()}
  def not_allowed(opts), do: NotAllowedError.exception(opts)

  @spec not_found([opt]) :: NotFoundError.t()
        when opt:
               {:details, map()}
               | {:entity, atom()}
  def not_found(opts), do: NotFoundError.exception(opts)

  @spec service([opt]) :: ServiceError.t()
        when opt: {:message, String.t()} | {:service, atom()}
  def service(opts), do: ServiceError.exception(opts)
end
