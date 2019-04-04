defmodule ScrumpokrWeb.VotingController do
  use ScrumpokrWeb, :controller
  alias Scrumpokr.Votings

  def create(conn, _params) do
    id = Votings.generate_random_id()
    redirect conn, to: Routes.live_path(conn, ScrumpokrWeb.VotingLive, id)
  end
end
