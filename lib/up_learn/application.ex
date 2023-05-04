defmodule UpLearn.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      UpLearnWeb.Telemetry,
      # Start the Ecto repository
      UpLearn.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: UpLearn.PubSub},
      # Start Finch
      {Finch, name: UpLearn.Finch},
      # Start the Endpoint (http/https)
      UpLearnWeb.Endpoint
      # Start a worker by calling: UpLearn.Worker.start_link(arg)
      # {UpLearn.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UpLearn.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    UpLearnWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
