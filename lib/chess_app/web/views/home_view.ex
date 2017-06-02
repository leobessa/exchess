defmodule ChessApp.Web.HomeView do
  use ChessApp.Web, :view

  def username(nil) do
    "(pending)"
  end
  def username(%{username: username}) do
    username
  end
end
