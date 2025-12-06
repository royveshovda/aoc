defmodule Y2019.D16Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2019, 16, async: true do
    test "part 1 with input" do
      assert Y2019.D16.p1(input_string()) == "69549155"
    end

    test "part 2 with input" do
      assert Y2019.D16.p2(input_string()) == "83253465"
    end
  end
end
