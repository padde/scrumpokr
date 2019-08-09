defmodule Scrumpokr.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Scrumpokr.Votings.Registry},
      Scrumpokr.Votings.Supervisor,
      ScrumpokrWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Scrumpokr.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    ScrumpokrWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
