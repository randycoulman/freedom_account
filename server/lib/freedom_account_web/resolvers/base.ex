defmodule FreedomAccountWeb.Resolvers.Base do
  defmacro __using__(_opts) do
    quote do
      @type resolution :: Absinthe.Resolution.t()
      @type result(t) ::
              {:ok, t}
              | Absinthe.Type.Field.error_result()
              | Absinthe.Type.Field.middleware_result()
    end
  end
end
