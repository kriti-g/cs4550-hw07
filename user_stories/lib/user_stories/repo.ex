defmodule UserStories.Repo do
  use Ecto.Repo,
    otp_app: :user_stories,
    adapter: Ecto.Adapters.Postgres
end
