defmodule UserStoriesWeb.PageController do
  use UserStoriesWeb, :controller

  alias UserStories.Events
  alias UserStories.Events.Event

  def index(conn, _params) do
    events = Events.list_events()
    render(conn, "index.html", events: events)
  end
end
