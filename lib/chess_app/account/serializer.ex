defmodule ChessApp.Account.Serializer do
  @behaviour Guardian.Serializer

  alias ChessApp.Account.Credential
  alias ChessApp.Account

  def for_token(%Credential{id: id}), do: { :ok, "Account:#{id}" }
  def for_token(_), do: { :error, "Unknown resource type" }

  def from_token("Account:" <> id), do: { :ok, Account.get_credential(id) }
  def from_token(_), do: { :error, "Unknown resource type" }
end
