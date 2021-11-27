defmodule FreedomAccountWeb.Plugs.AuthPipeline do
  use Guardian.Plug.Pipeline, module: FreedomAccountWeb.Authentication, otp_app: :freedom_account

  @claims %{aud: "freedom_account", iss: "freedom_account", typ: "access"}

  plug Guardian.Plug.VerifySession, claims: @claims
  plug Guardian.Plug.LoadResource, allow_blank: true
end
