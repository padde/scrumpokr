defmodule ScrumpokrWeb.CanonicalDomain do
  alias Plug.Conn
  alias Phoenix.Controller
  alias ScrumpokrWeb.Endpoint

  def init(options) do
    options
  end

  def call(conn, _options) do
    current_url = Conn.request_url(conn)

    if canonical?(current_url) do
      conn
    else
      conn
      |> Conn.put_status(:moved_permanently)
      |> Controller.redirect(external: canonicalize(current_url))
      |> Conn.halt()
    end
  end

  defp canonical?(current_url) do
    String.starts_with?(current_url, Endpoint.url())
  end

  defp canonicalize(current_url) do
    base = Endpoint.struct_url()
    current = URI.parse(current_url)

    URI.to_string(%{
      current
      | scheme: base.scheme,
        authority: base.authority,
        host: base.host,
        port: base.port
    })
  end
end
