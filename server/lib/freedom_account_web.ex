defmodule FreedomAccountWeb do
  @moduledoc """
  The entrypoint for the FreedomAccount web interface.
  """

  @spec controller :: Macro.t()
  def controller do
    quote do
      use Phoenix.Controller, namespace: FreedomAccountWeb

      import Plug.Conn
      import FreedomAccountWeb.Gettext
      alias FreedomAccountWeb.Router.Helpers, as: Routes
    end
  end

  @spec view :: Macro.t()
  def view do
    quote do
      use Phoenix.View,
        root: "lib/freedom_account_web/templates",
        namespace: FreedomAccountWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  @spec router :: Macro.t()
  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
    end
  end

  @spec channel :: Macro.t()
  def channel do
    quote do
      use Phoenix.Channel
      import FreedomAccountWeb.Gettext
    end
  end

  defp view_helpers do
    quote do
      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import FreedomAccountWeb.ErrorHelpers
      import FreedomAccountWeb.Gettext
      alias FreedomAccountWeb.Router.Helpers, as: Routes
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
