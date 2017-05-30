defmodule ChessApp.Account.Credential do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "account_credentials" do
    field :username, :string
    field :encrypted_password, :string
    field :password, :string, virtual: true

    timestamps()
  end

  def registration_changeset(model, params \\ %{}) do
    model
    |> cast(params, [:username, :password])
    |> validate_required([:username, :password])
    |> validate_length(:username, min: 3, max: 20)
    |> validate_length(:password, min: 5)
    |> unique_constraint(:username)
    |> generate_encrypted_password
  end

  defp generate_encrypted_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    put_change(changeset, :encrypted_password, Comeonin.Bcrypt.hashpwsalt(password))
  end
  defp generate_encrypted_password(%Ecto.Changeset{} = changeset) do
    changeset
  end

  def password_match?(%__MODULE__{encrypted_password: stored_hash}, password) do
    Comeonin.Bcrypt.checkpw(password, stored_hash)
  end

end
