defmodule ScrumpokrWeb.SecureBrowserHeaders do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    merge_resp_headers(conn, [
      {"content-security-policy", content_security_policy(conn)},
      {"referrer-policy", "no-referrer"},
      {"feature-policy", feature_policy()}
    ])
  end

  @webpack_dev_csp if Mix.env() == :dev, do: "'unsafe-inline' 'unsafe-eval'"

  defp content_security_policy(conn) do
    """
    default-src 'self'; \
    script-src 'self' #{@webpack_dev_csp}; \
    style-src 'self' #{@webpack_dev_csp} https://fonts.googleapis.com; \
    font-src 'self' https://fonts.gstatic.com; \
    connect-src 'self' #{ws_url(conn)}; \
    """
  end

  defp ws_url(conn) do
    url = Phoenix.Controller.endpoint_module(conn).struct_url

    ws_protocol =
      case url.scheme do
        "http" -> "ws"
        "https" -> "wss"
      end

    URI.to_string(%{url | scheme: ws_protocol})
  end

  defp feature_policy do
    """
    accelerometer 'none'; \
    ambient-light-sensor 'none'; \
    autoplay 'none'; \
    camera 'none'; \
    fullscreen 'none'; \
    gyroscope 'none'; \
    magnetometer 'none'; \
    microphone 'none'; \
    midi 'none'; \
    picture-in-picture 'none'; \
    sync-xhr 'none'; \
    usb 'none'; \
    """
  end
end
