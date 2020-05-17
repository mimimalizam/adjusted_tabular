defmodule Support.Benchmark do
  alias AdjustedTabular.Storage.Query

  def run do
    table = "benchee"
    pid = :foo_pid

    benches = %{
      "async.foo.seed.1e6" => fn ->
        set_up_table(table, pid)
        AdjustedTabular.Storage.Foo.seed_if_empty(table, 1..1_000_000, 20)
        Support.Factories.drop_table(pid, table)
      end,
      "async.foo.seed.2e6" => fn ->
        set_up_table(table, pid)
        AdjustedTabular.Storage.Foo.seed_if_empty(table, 1..2_000_000, 20)
        Support.Factories.drop_table(pid, table)
      end,
      "async.foo.seed.5e6" => fn ->
        set_up_table(table, pid)
        AdjustedTabular.Storage.Foo.seed_if_empty(table, 1..5_000_000, 20)
        Support.Factories.drop_table(pid, table)
      end,
      "foo.seed.1e6" => fn ->
        set_up_table(table, pid)
        seed(1..1_000_000, 20)
        Support.Factories.drop_table(pid, table)
      end,
      "foo.seed.2e6" => fn ->
        set_up_table(table, pid)
        seed(1..2_000_000, 20)
        Support.Factories.drop_table(pid, table)
      end,
      "foo.seed.5e6" => fn ->
        set_up_table(table, pid)
        seed(1..5_000_000, 20)
        Support.Factories.drop_table(pid, table)
      end
    }

    Benchee.run(
      benches,
      print: [fast_warning: false],
      memory_time: 0.001,
      warmup: 1,
      time: 2
    )
  end

  def set_up_table(table, pid) do
    AdjustedTabular.Storage.Database.set_up_table(
      table: table,
      pid: pid
    )
  end

  def seed(range, chunk_size) do
    query =
      Postgrex.prepare!(
        @pid,
        "",
        Query.compose_insert_rows(chunk_size, @table)
      )

    Stream.zip([range, Stream.cycle([1, 2, 0]), Stream.cycle([1, 2, 3, 4, 0])])
    |> Stream.map(&Tuple.to_list(&1))
    |> Stream.map(fn values -> run_query_in_transaction(@pid, query, values) end)
    |> Enum.to_list()
  end

  def run_query_in_transaction(pid, query, values) do
    pid
    |> Postgrex.transaction(fn conn -> Postgrex.execute(pid, query, values) end)
  end
end
