defmodule AdjustedTabular.Storage.Database do
  alias AdjustedTabular.Storage.Query
  @pg_env Application.get_env(:postgrex, :database_connection)

  def connect(db_name) do
    {:ok, pid} = env(database: db_name) |> Postgrex.start_link()
  end

  def set_up_table(table: table_name, db: db_name) do
    {:ok, pid} = connect(db_name)

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

  defp env(params \\ []), do: Keyword.merge(@pg_env, params)
end
