defmodule UserStories.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :date, :naive_datetime
    field :desc, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:name, :date, :desc])
    |> validate_required([:name, :desc])
  end
end
