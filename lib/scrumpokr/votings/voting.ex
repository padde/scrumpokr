defmodule Scrumpokr.Votings.Voting do
  use GenServer, restart: :transient

  @abandoned_timeout 5000

  defstruct id: nil,
            cards: [
              {"0", "0"},
              {"0.5", "½"},
              {"1", "1"},
              {"2", "2"},
              {"3", "3"},
              {"5", "5"},
              {"8", "8"},
              {"13", "13"},
              {"20", "20"},
              {"40", "40"},
              {"100", "100"},
              {"unknown", "?"},
              {"infinity", "\u{221e}"},
              {"pause", "\u{2615}"}
            ],
            votes: %{},
            force_reveal: false

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts[:id], opts)
  end

  def join(pid, user_id) do
    GenServer.cast(pid, {:join, user_id})
  end

  def vote(pid, user_id, value) do
    GenServer.cast(pid, {:vote, user_id, value})
  end

  def force_reveal(pid) do
    GenServer.cast(pid, :force_reveal)
  end

  def reset(pid) do
    GenServer.cast(pid, :reset)
  end

  def leave(pid, user_id) do
    GenServer.cast(pid, {:leave, user_id})
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  @impl true
  def init(voting_id) do
    {:ok, %__MODULE__{id: voting_id}}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:join, user_id}, state) do
    state = put_in(state.votes[user_id], nil)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:vote, user_id, value}, state) do
    state = put_in(state.votes[user_id], value)
    {:noreply, state}
  end

  @impl true
  def handle_cast(:force_reveal, state) do
    state = put_in(state.force_reveal, true)
    {:noreply, state}
  end

  @impl true
  def handle_cast(:reset, state) do
    state = %{
      state
      | force_reveal: false,
        votes:
          Enum.into(state.votes, %{}, fn {user_id, _vote} ->
            {user_id, nil}
          end)
    }

    {:noreply, state}
  end

  @impl true
  def handle_cast({:leave, user_id}, state) do
    {_vote, state} = pop_in(state.votes[user_id])

    if Enum.empty?(state.votes) do
      {:noreply, state, @abandoned_timeout}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_info(:timeout, state) do
    {:stop, :normal, state}
  end
end
