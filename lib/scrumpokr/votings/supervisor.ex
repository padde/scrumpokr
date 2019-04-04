defmodule Scrumpokr.Votings.Supervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_child(child_opts) do
    DynamicSupervisor.start_child(__MODULE__, {Scrumpokr.Votings.Voting, child_opts})
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
