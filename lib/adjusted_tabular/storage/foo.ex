defmodule AdjustedTabular.Storage.Foo do
  alias AdjustedTabular.Storage.Table
  require Logger

  def setup do
    table_name = "chunks"
    columns_definition = "a integer, b integer, c integer"

    {:ok, pid, _} =
      Table.create(
        table: table_name,
        db: "foo",
        columns: columns_definition
      )

    interval = 1..1_000_000
    chunk_size = 20

    query =
      Postgrex.prepare!(
        pid,
        "",
        compose_query_string(chunk_size)
      )

    Stream.zip([interval, Stream.cycle([1, 2, 0]), Stream.cycle([1, 2, 3, 4, 0])])
    |> Stream.map(&Tuple.to_list(&1))
    |> Stream.chunk_every(chunk_size)
    |> Task.async_stream(&process_chunk(&1, pid, query))
    |> Stream.run()
  end

  def process_chunk(chunk, pid, query) do
    run_query_in_transaction(pid, query, List.flatten(chunk))
  end

  def run_query_in_transaction(pid, query, values) do
    pid
    |> Postgrex.transaction(fn conn -> Postgrex.execute(pid, query, values) end)
  end

  def compose_query_string(params_count) do
    params_string = draft_query_params(params_count)

    "INSERT INTO test (a, b, c) VALUES #{params_string}"
  end

  def draft_query_params(n) do
    Enum.reduce(2..n, "($1, $2, $3)", fn n, acc ->
      a = (n - 1) * 3
      acc <> ", ($#{a + 1}, $#{a + 2}, $#{a + 3})"
    end)
  end
end
