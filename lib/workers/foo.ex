defmodule AdjustedTabular.Workers.Foo do
  alias AdjustedTabular.Workers.Table
  require Logger

  def setup do
    table_name = "source"
    columns_definition = "a integer, b integer, c integer"

    {:ok, pid, _} =
      Table.create(
        table: table_name,
        db: "foo",
        columns: columns_definition
      )

    interval = 1..1_000_000
    query = Postgrex.prepare!(pid, "", "INSERT INTO test(a, b, c) VALUES($1,$2,$3)")

    Stream.zip([interval, Stream.cycle([1, 2, 0]), Stream.cycle([1, 2, 3, 4, 0])])
    |> Stream.map(&Tuple.to_list(&1))
    |> Stream.map(fn values -> run_query_in_transaction(pid, query, values) end)
    |> Enum.to_list()
  end

  def run_query_in_transaction(pid, query, values) do
    pid
    |> Postgrex.transaction(fn conn -> Postgrex.execute(pid, query, values) end)
  end
end
