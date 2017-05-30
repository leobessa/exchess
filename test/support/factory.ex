defmodule ChessApp.Factory do
  use ExMachina.Ecto, repo: ChessApp.Repo

  @default_encrypted_password Comeonin.Bcrypt.hashpwsalt("secret")

  def credential_factory do
    %ChessApp.Account.Credential{
      username: sequence(:username, &"jon#{&1}"),
      encrypted_password: @default_encrypted_password,
    }
  end

  def with_password(%ChessApp.Account.Credential{} = credential,password) do
    %{credential | encrypted_password: Comeonin.Bcrypt.hashpwsalt(password)}
  end

  def match_factory do
    %ChessApp.Chess.Match{}
  end
end
