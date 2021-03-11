defmodule UserStoriesWeb.Helpers do
  alias UserStories.Users.User

  def current_user_id(conn) do
    user = conn.assigns[:current_user]
    user && user.id
  end

  def have_current_user?(conn) do
    conn.assigns[:current_user] != nil
  end

  def current_user_is?(conn, user_id) do
    current_user_id(conn) == user_id
  end

  def current_user_invited?(conn, invites) do
    current_id = current_user_id(conn)
    match_invite? = fn (inv) ->
      current_id == inv.user_id
    end
    Enum.any?(invites, match_invite?)
  end

end
