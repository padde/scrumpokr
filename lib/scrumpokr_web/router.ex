defmodule ScrumpokrWeb.Router do
  use ScrumpokrWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug ScrumpokrWeb.SecureBrowserHeaders
    plug :put_layout, {ScrumpokrWeb.LayoutView, "app.html"}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ScrumpokrWeb do
    pipe_through :browser

    get "/", PageController, :index

    post "/votings/create", VotingController, :create
    live "/:id", VotingLive, session: [:path_params, :user_id]
  end

  # Other scopes may use custom stacks.
  # scope "/api", ScrumpokrWeb do
  #   pipe_through :api
  # end
end
