defmodule AdjustedTabular.Storage.Query do
  alias AdjustedTabular.Storage.Database, as: DB
  require Logger

  def insert_row(pid, table, a, b, c) do
    Postgrex.query!(
      pid,
      "INSERT INTO #{table} (a, b, c) values(#{a}, #{b}, #{c})",
      []
    )
  end

  def create_table(pid, table) do
    columns_definition = "a integer, b integer, c integer"
    query = "CREATE TABLE #{table}(#{columns_definition})"

    Postgrex.query!(pid, query, [])
  end

  def compose_db_to_csv_query(db_name, table_name) do
    {:ok, pid} = DB.connect(db_name)
    s = "COPY (SELECT *FROM #{table_name}) to STDOUT WITH CSV DELIMITER ',';"

    {:ok, query} = Postgrex.prepare(pid, "csv", s)

    {pid, query}
  end

  def compose_insert_rows(params_count) do
    params_string = draft_query_params(params_count)

    "INSERT INTO test (a, b, c) VALUES #{params_string}"
  end

  defp draft_query_params(n) do
    Enum.reduce(2..n, "($1, $2, $3)", fn n, acc ->
      a = (n - 1) * 3
      acc <> ", ($#{a + 1}, $#{a + 2}, $#{a + 3})"
    end)
  end
end
