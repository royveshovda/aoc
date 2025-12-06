defmodule Y2023.D16Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2023, 16, async: true do
    test "part 1 with input" do
      assert Y2023.D16.p1(input_string()) == 7608
    end

    test "part 2 with input" do
      assert Y2023.D16.p2(input_string()) == 8221
    end
  end
end
