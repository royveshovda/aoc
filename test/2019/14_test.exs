defmodule Y2019.D14Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2019, 14, async: true do
    test "part 1 with input" do
      assert Y2019.D14.p1(input_string()) == 504284
    end

    test "part 2 with input" do
      assert Y2019.D14.p2(input_string()) == 2690795
    end
  end
end
