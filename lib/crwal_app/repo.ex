defmodule CrwalApp.Repo do
  use Ecto.Repo,
    otp_app: :crwal_app,
    adapter: Ecto.Adapters.Postgres
end
