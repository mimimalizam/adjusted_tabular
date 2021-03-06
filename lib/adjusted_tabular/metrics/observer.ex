defmodule AdjustedTabular.Metrics.Observer do
  require Logger

  def handle_event([:http, :request], %{duration: dur}, metadata, _config) do
    # do some stuff like log a message or report metrics to a service like StatsD
    Logger.info(
      "Received [:http, :request] event. Request duration: #{dur}, Route: #{metadata.request_path}"
    )
  end
end
