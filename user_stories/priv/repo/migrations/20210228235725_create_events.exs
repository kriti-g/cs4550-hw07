defmodule UserStories.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :name, :string, null: false
      add :date, :naive_datetime, null: false
      add :desc, :text, null: false
      add :user, references(:users), null: false

      timestamps()
    end

  end
end
