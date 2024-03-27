defmodule Zhongzi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ZhongziWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:zhongzi, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Zhongzi.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Zhongzi.Finch},
      # Start a worker by calling: Zhongzi.Worker.start_link(arg)
      # {Zhongzi.Worker, arg},
      # Start to serve requests, typically the last entry
      ZhongziWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Zhongzi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ZhongziWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
