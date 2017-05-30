defmodule ChessApp.AccountTest do
  use ChessApp.DataCase

  alias ChessApp.Account

  describe "credentials" do
    alias ChessApp.Account.Credential

    @valid_attrs %{password: "secret123", username: "jon"}

    def credential_fixture(attrs \\ %{}) do
      {:ok, credential} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Account.create_credential()

      credential
    end

    test "list_credentials/0 returns all credentials" do
      credential = credential_fixture()
      credential = %{credential | password: nil}
      assert Account.list_credentials() == [credential]
    end

    test "get_credential!/1 returns the credential with given id" do
      credential = credential_fixture()
      credential = %{credential | password: nil}
      assert Account.get_credential!(credential.id) == credential
    end

    test "create_credential/1 with valid data creates a credential" do
      attrs = %{password: "secret123", username: "jon"}
      assert {:ok, %Credential{} = credential} = Account.create_credential(attrs)
      assert credential.username == "jon"
      assert Credential.password_match?(credential, "secret123")
    end

    test "create_credential/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Account.create_credential(%{password: nil, username: "jon"})
    end
  end

  describe "auth_tokens" do
    test "create_auth_token/1 with valid data creates a credential" do
      attrs = %{password: "secret123", username: "jon"}
      {:ok, _credential} = Account.create_credential(attrs)
      {:ok, auth_token}  = Account.create_auth_token("jon","secret123")
      assert auth_token
    end

    test "create_credential/1 with invalid data returns :invalid_credential error" do
      assert {:error, :invalid_credential} = Account.create_auth_token("jon", nil)
    end
  end
end
