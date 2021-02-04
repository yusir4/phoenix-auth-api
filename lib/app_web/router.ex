defmodule MainModuleWeb.Router do
  use MainModuleWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  pipeline :api_auth do
    plug :ensure_authenticated
  end

  # Plug function
  defp ensure_authenticated(conn, _opts) do
    current_user_id = get_session(conn, :current_user_id)

    if current_user_id do
      conn
      |> json(%{data: %{current_user_id: current_user_id}})

    else
      conn
      |> put_status(:unauthorized)
      |> put_view(MainModuleWeb.ErrorView)
      |> render("401.json", message: "Unauthenticated user")
      |> halt()
    end
  end

  scope "/api", MainModuleWeb do
    pipe_through :api
    post "/users/login", UserController, :sign_in
    post "/users/register", UserController, :create
  end

  scope "/api", MainModuleWeb do
    pipe_through [:api, :api_auth]
    resources "/users", UserController, except: [:new, :edit, :create]
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: MainModuleWeb.Telemetry
    end
  end
end
