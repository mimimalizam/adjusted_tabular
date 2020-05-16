defmodule Mix.Tasks.Seed do
  use Mix.Task
  require Logger

  def run(_) do
    {:ok, _started} = Application.ensure_all_started(:postgrex)

    Logger.info("🌱 Seeding table source in foo database")

    AdjustedTabular.Storage.Foo.seed("source")
    Logger.info("✅ Done...")

    Logger.info("🌱 Seeding table dest in bar database")

    AdjustedTabular.Storage.Bar.seed()
    Logger.info("✅ Done...")
  end
end
