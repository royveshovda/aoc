defmodule Y2019.D25Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2019, 25, async: true do
    test "part 1 with input" do
      assert Y2019.D25.p1(input_string()) == "1109393410"
    end

    # Day 25 typically only has Part 1
  end
end
