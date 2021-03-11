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

  def which_responses?(conn, invites) do
    inc_which? = fn (inv, arr) ->
      [yes, maybe, no, pending] = arr
      case inv.response do
        :Yes -> [yes + 1, maybe, no, pending]
        :No -> [yes, maybe, no+1, pending]
        :Maybe -> [yes, maybe+1, no, pending]
        :Pending -> [yes, maybe, no, pending+1]
      end
    end
    [yeses, maybes, nos, pendings] = Enum.reduce(invites, [0, 0, 0, 0], inc_which?)
    to_string(yeses) <> " yes, " <> to_string(maybes) <> " maybe, " <> to_string(nos) <> " no, " <> to_string(pendings) <> " haven't responded."
  end

end
