defmodule AdjustedTabular.Storage.FooTest do
  use ExUnit.Case

  alias AdjustedTabular.Storage.Query

  describe "seed" do
    test "when source table has data, it doesn't add new rows" do
      assert Query.compose_insert_rows(3, "test") ==
               "INSERT INTO test (a, b, c) VALUES ($1, $2, $3), ($4, $5, $6), ($7, $8, $9)"
    end
  end
end
