defmodule Mix.Tasks.Seed do
  use Mix.Task

  def run(_) do
    {:ok, _started} = Application.ensure_all_started(:postgrex)

    IO.inspect("Seeding table source in foo database")

    AdjustedTabular.Storage.Foo.seed()
    IO.inspect("Done...")

    IO.inspect("Seeding table dest in bar database")

    AdjustedTabular.Storage.Bar.seed()
    IO.inspect("Done...")
  end
end
