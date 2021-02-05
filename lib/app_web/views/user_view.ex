defmodule MainModuleWeb.UserView do
  use MainModuleWeb, :view
  alias MainModuleWeb.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      email: user.email,
      name: user.name,
      surname: user.surname}
  end

  def render("debug.json", %{arg: arg}) do
    %{
      data: arg
    }
  end

  def render("access_token.json", %{token: token}) do
    %{
      data: %{
        access_token: token
      }
    }
  end

  def render("refresh_token.json", %{token: token}) do
    %{
      data: %{
        refresh_token: token
      }
    }
  end
end
