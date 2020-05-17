defmodule AdjustedTabular.Storage.Query do
  alias AdjustedTabular.Storage.Database, as: DB
  require Logger

  def table_is_empty?(pid, table_name) do
    row_count(pid, table_name) == {pid, 0}
  end

  def create_table(pid, table) do
    columns_definition = "a integer, b integer, c integer"
    query = "CREATE TABLE #{table}(#{columns_definition})"

    Postgrex.query!(pid, query, [])
  end

  def row_count(pid, table_name) do
    %Postgrex.Result{rows: [[n]]} =
      "SELECT COUNT(*) FROM #{table_name};"
      |> prepare_and_execute!(pid)

    {pid, n}
  end

  def compose_db_to_csv_query(db_name, table_name) do
    pid = DB.get_pid(db_name)

    {:ok, query} =
      Postgrex.prepare(
        pid,
        "csv",
        "COPY (SELECT *FROM #{table_name}) to STDOUT WITH CSV DELIMITER ',';"
      )

    {pid, query}
  end

  def compose_insert_rows(insert_values_count, table_name) do
    params_string = draft_query_params(insert_values_count)

    "INSERT INTO #{table_name} (a, b, c) VALUES #{params_string}"
  end

  def prepare_and_execute!(query_string, pid) do
    query_string
    |> (&Postgrex.prepare!(pid, "", &1)).()
    |> (&Postgrex.execute!(pid, &1, [])).()
  end

  defp draft_query_params(1), do: "($1, $2, $3)"

  defp draft_query_params(n) do
    Enum.reduce(2..n, "($1, $2, $3)", fn n, acc ->
      a = (n - 1) * 3

      acc <> ", ($#{a + 1}, $#{a + 2}, $#{a + 3})"
    end)
  end
end
