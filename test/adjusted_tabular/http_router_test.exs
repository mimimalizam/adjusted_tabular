defmodule AdjustedTabular.HttpRouterTest do
  use ExUnit.Case

  setup do
    HTTPoison.start
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
end
