defmodule AdjustedTabular.HttpRouterTest do
  use ExUnit.Case

  alias AdjustedTabular.Storage

  @base_url "http://localhost:4000"

  setup do
    setup_test_db

    HTTPoison.start()
    :ok
  end

  describe "get /is_alive" do
    test "returns OK" do
      {:ok, response} = HTTPoison.get("#{@base_url}/is_alive")

      assert response.status_code == 200
      assert response.body == "ok"
    end
  end

  describe "get /dbs/:db_name/tables/:table_name" do
    test "when db and table exist, the response is chunked" do
      url = "#{@base_url}/dbs/foo/tables/test"
      %HTTPoison.AsyncResponse{id: id} = HTTPoison.get!(url, %{}, stream_to: self())

      assert_receive %HTTPoison.AsyncStatus{id: ^id, code: 200}, 1_000
      assert_receive %HTTPoison.AsyncHeaders{id: ^id, headers: headers}, 1_000
      assert_receive %HTTPoison.AsyncChunk{id: ^id, chunk: _chunk}, 1_000
      assert_receive %HTTPoison.AsyncEnd{id: ^id}, 1_000
      assert is_list(headers)
    end

    test "when db and table exist, the response header includes csv header" do
      url = "#{@base_url}/dbs/foo/tables/test"
      %HTTPoison.AsyncResponse{id: id} = HTTPoison.get!(url, %{}, stream_to: self())

      assert_receive %HTTPoison.AsyncHeaders{id: ^id, headers: h}, 1_000

      headers = Enum.into(h, %{})
      assert headers["content-type"] =~ "application/csv"
    end

    test "when db and table exist, the response is correct" do
      url = "#{@base_url}/dbs/foo/tables/test"
      {response, _} = System.cmd("curl", ["--raw", url])

      assert response ==
        "1E\r\n1,1,1\n2,2,2\n3,0,3\n4,1,4\n5,2,0\n\r\n0\r\n\r\n"
    end
  end

  defp drop_test_db() do
    {:ok, pid} = Storage.Database.connect("foo")
    s = "DROP TABLE IF EXISTS test;"

    Postgrex.query!(pid, s, [])
  end

  defp setup_test_db() do
    drop_test_db()

    with {:ok, pid, _} <- Storage.Database.set_up_table(table: "test", db: "foo") do
      :ok =
        Enum.each(
          1..5,
          fn i -> Storage.Query.insert_row(pid, "test", i, rem(i, 3), rem(i, 5)) end
        )
    else
      e ->
        require Logger
        Logger.error(inspect(e))
    end
  end
end
