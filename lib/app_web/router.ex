defmodule MainModuleWeb.Router do
  use MainModuleWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", MainModuleWeb do
    pipe_through :api
    resources "/users", UserController, except: [:new, :edit]
    post "/users/sign_in", UserController, :sign_in
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: MainModuleWeb.Telemetry
    end
  end
end
