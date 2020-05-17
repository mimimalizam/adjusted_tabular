defmodule AdjustedTabular.Storage.Database do
  alias AdjustedTabular.Storage.Query
  @pg_env Application.get_env(:postgrex, :database_connection)

  def conn_config(:foo), do: Keyword.merge(@pg_env, database: "foo", name: :foo_pid)
  def conn_config(:bar), do: Keyword.merge(@pg_env, database: "bar", name: :bar_pid)

  def set_up_table(table: table_name, pid: pid) do
    try do
      {:ok, pid, Query.create_table(pid, table_name)}
    rescue
      e in Postgrex.Error ->
        case parse_error(e) do
          :table_exists ->
            {:ok, pid, :table_exists}

          :unhandled_error ->
            {:error, e}
        end

      e ->
        require Logger
        Logger.error(inspect(e))
        Kernel.reraise(e, __STACKTRACE__)
    end
  end

  defp parse_error(%Postgrex.Error{postgres: %{code: :duplicate_table}}), do: :table_exists
  defp parse_error(_), do: :unhandled_error

  def get_pid("foo"), do: :foo_pid
  def get_pid("bar"), do: :bar_pid
end
