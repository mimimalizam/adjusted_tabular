defmodule AdjustedTabular.HttpRouterTest do
  use ExUnit.Case

  setup do
    HTTPoison.start()
    :ok
  end

  @base_url "http://localhost:4000"

  describe "get /is_alive" do
    test "returns OK" do
      {:ok, response} = HTTPoison.get("#{@base_url}/is_alive")

      assert response.status_code == 200
      assert response.body == "ok"
    end
  end

  describe "get /chunked" do
    test "the response is chunked" do
      url = "#{@base_url}/chunked"
      %HTTPoison.AsyncResponse{id: id} = HTTPoison.get!(url, %{}, stream_to: self())

      assert_receive %HTTPoison.AsyncStatus{id: ^id, code: 200}, 1_000
      assert_receive %HTTPoison.AsyncHeaders{id: ^id, headers: headers}, 1_000
      assert_receive %HTTPoison.AsyncChunk{id: ^id, chunk: _chunk}, 1_000
      assert_receive %HTTPoison.AsyncEnd{id: ^id}, 1_000
      assert is_list(headers)
    end

    test "the response header includes csv header" do
      url = "#{@base_url}/chunked"
      %HTTPoison.AsyncResponse{id: id} = HTTPoison.get!(url, %{}, stream_to: self())

      assert_receive %HTTPoison.AsyncHeaders{id: ^id, headers: h}, 1_000

      headers = Enum.into(h, %{})
      assert headers["content-type"] =~ "application/csv"
    end
  end
end
