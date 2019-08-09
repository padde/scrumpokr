defmodule Scrumpokr.Votings do
  alias Scrumpokr.Votings.Supervisor
  alias Scrumpokr.Votings.Voting

  @alphabet ~w[a b c d e f g h i j k l m n o p q r s t u v w x y z]

  def ready?(%Voting{} = voting) do
    Enum.count(voting.votes) > 1
  end

  def revealed?(%Voting{force_reveal: true}) do
    true
  end

  def revealed?(%Voting{} = voting) do
    ready?(voting) &&
      voting.votes |> Map.values() |> Enum.all?(& &1)
  end

  def voted?(%Voting{} = voting) do
    voting.votes |> Map.values() |> Enum.any?(& &1)
  end

  def voted?(%Voting{} = voting, user_id) do
    not is_nil(Map.get(voting.votes, user_id))
  end

  def participating?(%Voting{} = voting, user_id) do
    Map.has_key?(voting.votes, user_id)
  end

  def generate_random_id do
    Stream.repeatedly(fn -> Enum.random(@alphabet) end)
    |> Stream.take(9)
    |> Stream.chunk_every(3)
    |> Enum.join("-")
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

  def force_reveal(voting_id) do
    name(voting_id) |> Voting.force_reveal()
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
