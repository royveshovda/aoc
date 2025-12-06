defmodule Y2023.D25Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2023, 25, async: true do
    test "part 1 with input" do
      assert Y2023.D25.p1(input_string()) == 544523
    end
  end
end
