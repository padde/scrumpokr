defmodule ScrumpokrWeb.VotingView do
  use ScrumpokrWeb, :view

  defdelegate complete?(voting), to: Scrumpokr.Votings
end
