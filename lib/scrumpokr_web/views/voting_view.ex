defmodule ScrumpokrWeb.VotingView do
  use ScrumpokrWeb, :view

  defdelegate ready?(voting), to: Scrumpokr.Votings
  defdelegate voted?(voting), to: Scrumpokr.Votings
  defdelegate voted?(voting, user_id), to: Scrumpokr.Votings
  defdelegate revealed?(voting), to: Scrumpokr.Votings
  defdelegate participating?(voting, user_id), to: Scrumpokr.Votings

  def card_label(voting, value) do
    voting.cards
    |> List.keyfind(value, 0)
    |> elem(1)
  end
end
