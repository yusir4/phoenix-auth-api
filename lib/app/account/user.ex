defmodule MainModule.Account.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :surname, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :surname])
    |> validate_required([:email, :name, :surname])
    |> unique_constraint(:email)
  end
end
