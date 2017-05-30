defmodule ChessApp.Account.AuthToken do
  defstruct [:jwt, :account_id]

  alias ChessApp.Account.{AuthToken,Credential}

  def from_credential(%Credential{id: account_id} = credential) do
    {:ok, jwt, _claims} = Guardian.encode_and_sign(credential, :access)
    {:ok, %AuthToken{account_id: account_id, jwt: jwt}}
  end
end
