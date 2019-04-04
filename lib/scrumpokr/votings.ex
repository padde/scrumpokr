defmodule Scrumpokr.Votings do
  alias Scrumpokr.Votings.Supervisor
  alias Scrumpokr.Votings.Voting

  def complete?(%Voting{} = voting) do
    voting.votes |> Map.values() |> Enum.all?(& &1)
  end

  def join(voting_id, user_id) do
    case Supervisor.start_child(id: voting_id, name: name(voting_id)) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
    end
    name(voting_id) |> Voting.join(user_id)
  end

  def monitor(voting_id, callback_fun) do
    name(voting_id) |> Voting.monitor(self(), callback_fun)
  end

  def get_state(voting_id) do
    name(voting_id) |> Voting.get_state()
  end

  def vote(voting_id, user_id, value) do
    name(voting_id) |> Voting.vote(user_id, value)
  end

  def reset(voting_id) do
    name(voting_id) |> Voting.reset()
  end

  def leave(voting_id, user_id) do
    name(voting_id) |> Voting.leave(user_id)
  end

  defp name(voting_id) do
    {:via, Registry, {Scrumpokr.Votings.Registry, voting_id}}
  end
end
