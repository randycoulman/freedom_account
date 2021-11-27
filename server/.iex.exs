defmodule H do
  alias FreedomAccountWeb.Authentication

  def session_token(cookie) do
    cookie
    |> decode_session()
    |> decode_token()
  end

  def decode_session(cookie) do
    [_, payload, _] = String.split(cookie, ".", parts: 3)
    {:ok, encoded_term} = Base.url_decode64(payload, padding: false)
    :erlang.binary_to_term(encoded_term)
  end

  defp decode_token(%{"guardian_default_token" => token}) do
    Authentication.decode_and_verify(token)
  end

  defp decode_token(session), do: %{}
end

Application.put_env(:elixir, :ansi_enabled, true)

IEx.configure(colors: [enabled: true])
