defmodule ChessApp.Web.CredentialView do
  use ChessApp.Web, :view
  alias ChessApp.Web.CredentialView

  def render("show.json", %{credential: credential}) do
    %{data: render_one(credential, CredentialView, "credential.json")}
  end

  def render("credential.json", %{credential: credential}) do
    %{id: credential.id, username: credential.username}
  end
end
