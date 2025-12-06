defmodule Y2023.D13Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2023, 13, async: true do
    test "part 1 with input" do
      assert Y2023.D13.p1(input_string()) == 37975
    end

    test "part 2 with input" do
      assert Y2023.D13.p2(input_string()) == 32497
    end
  end
end
