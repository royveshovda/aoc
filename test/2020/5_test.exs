defmodule Y2020.D5Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2020, 5, async: true do
    test "part 1 with input" do
      assert Y2020.D5.p1(input_string()) == 816
    end

    test "part 2 with input" do
      assert Y2020.D5.p2(input_string()) == 539
    end
  end
end
