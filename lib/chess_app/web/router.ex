defmodule ChessApp.Web.Router do
  use ChessApp.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ChessApp.Web do
    pipe_through :api
  end
end
