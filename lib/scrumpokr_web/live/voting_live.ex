defmodule ScrumpokrWeb.VotingLive do
  use ScrumpokrWeb, :live

  alias Scrumpokr.Votings

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
    {:ok, refresh(socket)}
  end

  @impl true
  def handle_event("vote", value, socket) do
    Votings.vote(socket.assigns[:voting_id], socket.assigns[:user_id], value)
    {:noreply, socket}
  end

  @impl true
  def handle_event("become_observer", _value, socket) do
    Votings.leave(socket.assigns[:voting_id], socket.assigns[:user_id])
    {:noreply, socket}
  end

  @impl true
  def handle_event("become_voter", _value, socket) do
    Votings.join(socket.assigns[:voting_id], socket.assigns[:user_id])
    {:noreply, socket}
  end

  @impl true
  def handle_event("force_reveal", _value, socket) do
    Votings.force_reveal(socket.assigns[:voting_id])
    {:noreply, socket}
  end

  @impl true
  def handle_event("reset", _value, socket) do
    Votings.reset(socket.assigns[:voting_id])
    {:noreply, socket}
  end

  @impl true
  def handle_info(:refresh, socket) do
    {:noreply, socket}
  end

  defp refresh(socket) do
    state = Votings.get_state(socket.assigns[:voting_id])
    assign(socket, :voting, state)
  end
end
