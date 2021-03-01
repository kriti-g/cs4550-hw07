defmodule UserStories.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :name, :string
      add :user, :string
      add :date, :naive_datetime
      add :desc, :string

      timestamps()
    end

  end
end
