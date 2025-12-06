defmodule Y2022.D5Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2022, 5, async: true do
    test "part 1 with input" do
      assert Y2022.D5.p1(input_string()) == "FZCMJCRHZ"
    end

    test "part 2 with input" do
      assert Y2022.D5.p2(input_string()) == "JSDHQMZGF"
    end
  end
end
