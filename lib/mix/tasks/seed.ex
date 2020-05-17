defmodule Mix.Tasks.Seed do
  use Mix.Task
  require Logger

  def run(_) do
    {:ok, _started} = Application.ensure_all_started(:postgrex)
    AdjustedTabular.Storage.Seed.run()
  end
end
