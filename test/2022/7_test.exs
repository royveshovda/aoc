defmodule Y2022.D7Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2022, 7, async: true do
    test "part 1 with input" do
      assert Y2022.D7.p1(input_string()) == 1449447
    end

    test "part 2 with input" do
      assert Y2022.D7.p2(input_string()) == 8679207
    end
  end
end
