defmodule Y2020.D16Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2020, 16, async: true do
    test "part 1 with input" do
      assert Y2020.D16.p1(input_string()) == 23009
    end

    test "part 2 with input" do
      assert Y2020.D16.p2(input_string()) == 10458887314153
    end
  end
end
