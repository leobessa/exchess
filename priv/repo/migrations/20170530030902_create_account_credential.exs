defmodule ChessApp.Repo.Migrations.CreateChessApp.Account.Credential do
  use Ecto.Migration

  def change do
    create table(:account_credentials, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :username, :string, null: false
      add :encrypted_password, :string, null: false

      timestamps()
    end
    create unique_index(:account_credentials, [:username])

  end
end
