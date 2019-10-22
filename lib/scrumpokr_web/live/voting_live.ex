defmodule ScrumpokrWeb.VotingLive do
  use ScrumpokrWeb, :live

  alias Scrumpokr.Votings
  alias Phoenix.PubSub

  @pubsub Application.fetch_env!(:scrumpokr, ScrumpokrWeb.Endpoint)
          |> Keyword.fetch!(:pubsub)
          |> Keyword.fetch!(:name)

  @impl true
  def render(assigns) do
    ScrumpokrWeb.VotingView.render("live.html", assigns)
  end

  @impl true
  def mount(session, socket) do
    socket =
      socket
      |> assign(:voting_id, session.path_params["id"])
      |> assign(:user_id, socket.id)

    Votings.join(socket.assigns[:voting_id], socket.assigns[:user_id])

    Votings.monitor(socket.assigns[:voting_id], fn ->
      Votings.leave(socket.assigns[:voting_id], socket.assigns[:user_id])
      PubSub.broadcast(@pubsub, topic(socket), :refresh)
      PubSub.unsubscribe(@pubsub, topic(socket))
    end)

    PubSub.subscribe(@pubsub, topic(socket))
    PubSub.broadcast_from(@pubsub, self(), topic(socket), :refresh)
    {:ok, refresh(socket)}
  end

  @impl true
  def handle_event("vote", %{"card-value" => value}, socket) do
    Votings.vote(socket.assigns[:voting_id], socket.assigns[:user_id], value)
    PubSub.broadcast(@pubsub, topic(socket), :refresh)
    {:noreply, socket}
  end

  @impl true
  def handle_event("become_observer", _params, socket) do
    Votings.leave(socket.assigns[:voting_id], socket.assigns[:user_id])
    PubSub.broadcast(@pubsub, topic(socket), :refresh)
    {:noreply, socket}
  end

  @impl true
  def handle_event("become_voter", _params, socket) do
    Votings.join(socket.assigns[:voting_id], socket.assigns[:user_id])
    PubSub.broadcast(@pubsub, topic(socket), :refresh)
    {:noreply, socket}
  end

  @impl true
  def handle_event("force_reveal", _params, socket) do
    Votings.force_reveal(socket.assigns[:voting_id])
    PubSub.broadcast(@pubsub, topic(socket), :refresh)
    {:noreply, socket}
  end

  @impl true
  def handle_event("reset", _params, socket) do
    Votings.reset(socket.assigns[:voting_id])
    PubSub.broadcast(@pubsub, topic(socket), :refresh)
    {:noreply, socket}
  end

  def handle_info(:refresh, socket) do
    {:noreply, refresh(socket)}
  end

  defp topic(socket) do
    "voting:#{socket.assigns[:voting_id]}"
  end

  defp refresh(socket) do
    state = Votings.get_state(socket.assigns[:voting_id])
    assign(socket, :voting, state)
  end
end
