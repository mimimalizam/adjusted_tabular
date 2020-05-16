defmodule AdjustedTabular.Storage.QueryTest do
  use ExUnit.Case

  alias AdjustedTabular.Storage.Query

  describe "compose_insert_rows" do
    test "it returns correct insert query string" do
      assert Query.compose_insert_rows(3, "test") ==
               "INSERT INTO test (a, b, c) VALUES ($1, $2, $3), ($4, $5, $6), ($7, $8, $9)"
    end
  end
end
