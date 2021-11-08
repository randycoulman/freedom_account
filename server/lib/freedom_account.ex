defmodule FreedomAccount do
  @moduledoc """
  FreedomAccount domain and business logic.
  """

  use Knigge,
    config_key: :freedom_account,
    default: __MODULE__.Impl,
    otp_app: :freedom_account

  @type account :: %{
          id: String.t(),
          name: String.t()
        }
  @type fund :: %{
          icon: String.t(),
          id: String.t(),
          name: String.t()
        }

  @callback list_funds(account) :: {:ok, [fund]} | {:error, term}
  @callback my_account :: {:ok, account} | {:error, term}
end

defmodule FreedomAccount.Impl do
  @moduledoc false

  @behaviour FreedomAccount

  @fake_account %{
    id: "100",
    name: "Initial Account"
  }

  @fake_funds [
    %{
      icon: "🏚️",
      id: "1",
      name: "Home Repairs"
    },
    %{
      icon: "🚘",
      id: "2",
      name: "Car Repairs"
    },
    %{
      icon: "💸",
      id: "3",
      name: "Property Taxes"
    }
  ]

  @impl FreedomAccount
  def list_funds(_account) do
    {:ok, @fake_funds}
  end

  @impl FreedomAccount
  def my_account do
    {:ok, @fake_account}
  end
end
