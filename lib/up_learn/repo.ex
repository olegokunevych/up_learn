defmodule UpLearn.Repo do
  use Ecto.Repo,
    otp_app: :up_learn,
    adapter: Ecto.Adapters.Postgres
end
