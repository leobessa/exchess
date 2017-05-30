defmodule ChessApp.Web.AuthTokenView do
  use ChessApp.Web, :view
  alias ChessApp.Web.AuthTokenView
  alias ChessApp.Account.AuthToken

  def render("show.json", %{auth_token: %AuthToken{} = auth_token}) do
    %{data: render_one(auth_token, AuthTokenView, "auth_token.json")}
  end

  def render("auth_token.json", %{auth_token: %AuthToken{} = auth_token}) do
    %{account_id: auth_token.account_id, jwt: auth_token.jwt}
  end
end
