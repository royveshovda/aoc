defmodule Y2020.D24Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2020, 24, async: true do
    test "part 1 with input" do
      assert Y2020.D24.p1(input_string()) == 450
    end

    test "part 2 with input" do
      assert Y2020.D24.p2(input_string()) == 4059
    end
  end
end
