defmodule Brimbelle.Repo do
  use Ecto.Repo,
    otp_app: :brimbelle,
    adapter: Ecto.Adapters.SQLite3
end
