defmodule FreedomAccountWeb.Plugs.AuthPipeline do
  @moduledoc """
  Pipeline for processing authentication information.

  Looks for an auth token in the session, and if found, loads the associated
  resource. Ensuring that there is an authenticated user is done in GraphQL
  resolvers, so this pipeline doesn't check for that, nor raise an error if
  there is no resource to load.
  """

  use Guardian.Plug.Pipeline, module: FreedomAccountWeb.Authentication, otp_app: :freedom_account

  @claims %{aud: "freedom_account", iss: "freedom_account", typ: "access"}

  plug Guardian.Plug.VerifySession, claims: @claims
  plug Guardian.Plug.LoadResource, allow_blank: true
end
