defmodule ChessApp.Web.Router do
  use ChessApp.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ChessApp.Web, as: :api do
    pipe_through :api
    post "/accounts", CredentialController, :create, as: :signup
  end
end
