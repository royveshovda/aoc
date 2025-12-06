defmodule Y2020.D15Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2020, 15, async: true do
    test "part 1 with input" do
      assert Y2020.D15.p1(input_string()) == 1428
    end

    test "part 2 with input" do
      assert Y2020.D15.p2(input_string()) == 3718541
    end
  end
end
