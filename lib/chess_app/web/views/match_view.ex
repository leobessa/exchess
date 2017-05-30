defmodule ChessApp.Web.MatchView do
  use ChessApp.Web, :view
  alias ChessApp.Web.MatchView

  def render("show.json", %{match: match}) do
    %{data: render_one(match, MatchView, "match.json")}
  end

  def render("index.json", %{matches: matches}) do
    %{data: render_many(matches, MatchView, "match.json")}
  end

  def render("match.json", %{match: match}) do
    match
    |> Map.take(~w(id player1_id player2_id finished)a)
  end

end
