# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     UserStories.Repo.insert!(%UserStories.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias UserStories.Repo
alias UserStories.Users.User
alias UserStories.Events.Event
alias UserStories.Photos

hash = Photos.get_default()

alice = Repo.insert!(%User{name: "alice", photo_hash: hash, email: "alice@email.com"})
bob = Repo.insert!(%User{name: "bob", photo_hash: hash, email: "bob@email.com"})

p1 = %Event{
  user_id: alice.id,
  name: "Alice Post",
  desc: "Alice says Hi!",
  date: ~N[2001-01-01 23:00:00]
}
Repo.insert!(p1)

p2 = %Event{
  user_id: bob.id,
  name: "Bob Post",
  desc: "Bob says garblarg!",
  date: ~N[2004-01-19 23:00:00]
}
Repo.insert!(p2)
