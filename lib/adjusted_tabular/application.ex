defmodule AdjustedTabular.Application do
  @moduledoc false
  use Application

  require Logger
  import Supervisor.Spec

  alias AdjustedTabular.Storage.Database, as: DB

  def start(_type, _args) do
    Logger.info("Running application in #{Mix.env()} environment")

    :ok =
      :telemetry.attach(
        # unique handler id
        "http-router-metrics",
        [:http, :request],
        &AdjustedTabular.Metrics.Observer.handle_event/4,
        nil
      )

    Supervisor.start_link(children, options)
  end

  defp children do
    children = [
      AdjustedTabular.HttpRouter,
      Supervisor.child_spec({Postgrex, DB.conn_config(:foo)}, id: :foo),
      Supervisor.child_spec({Postgrex, DB.conn_config(:bar)}, id: :bar)
    ]

    children
  end

  defp options do
    [
      strategy: :one_for_one,
      name: AdjustedTabular.Supervisor
    ]
  end
end
