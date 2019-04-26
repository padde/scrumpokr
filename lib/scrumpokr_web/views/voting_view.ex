defmodule ScrumpokrWeb.VotingView do
  use ScrumpokrWeb, :view

  defdelegate complete?(voting), to: Scrumpokr.Votings
  defdelegate participating?(voting, user_id), to: Scrumpokr.Votings
end
