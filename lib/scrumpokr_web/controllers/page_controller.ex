defmodule ScrumpokrWeb.PageController do
  use ScrumpokrWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
