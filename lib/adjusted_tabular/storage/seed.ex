defmodule AdjustedTabular.Storage.Seed do
  def run() do
    AdjustedTabular.Storage.Foo.seed("source")
    AdjustedTabular.Storage.Bar.seed("dest")
  end
end
