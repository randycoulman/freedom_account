defmodule FreedomAccountWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use FreedomAccountWeb, :controller
      use FreedomAccountWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """
  use Boundary, deps: [FreedomAccount], exports: [Endpoint]

  @spec static_paths :: [String.t()]
  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  @spec router :: Macro.t()
  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Phoenix.Controller
      import Phoenix.LiveView.Router
      import Plug.Conn
    end
  end

  @spec channel :: Macro.t()
  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  @spec controller :: Macro.t()
  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json]

      use Gettext, backend: FreedomAccountWeb.Gettext

      import Plug.Conn

      unquote(verified_routes())
    end
  end

  @spec live_view :: Macro.t()
  def live_view do
    quote do
      use Phoenix.LiveView

      import FreedomAccountWeb.SocketHelpers

      unquote(html_helpers())
    end
  end

  @spec live_component :: Macro.t()
  def live_component do
    quote do
      use Phoenix.LiveComponent

      import FreedomAccountWeb.SocketHelpers

      unquote(html_helpers())
    end
  end

  @spec html :: Macro.t()
  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      # Core UI components and translation
      use Gettext, backend: FreedomAccountWeb.Gettext

      import FreedomAccountWeb.CoreComponents
      import Phoenix.HTML

      # Common modules used in templates
      alias FreedomAccountWeb.Layouts
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  @spec verified_routes :: Macro.t()
  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: FreedomAccountWeb.Endpoint,
        router: FreedomAccountWeb.Router,
        statics: FreedomAccountWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
