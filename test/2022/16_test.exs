defmodule Y2022.D16Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2022, 16, async: true do
    test "part 1 with input" do
      assert Y2022.D16.p1(input_string()) == 1751
    end

    test "part 2 with input" do
      assert Y2022.D16.p2(input_string()) == 2207
    end
  end
end
