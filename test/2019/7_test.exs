defmodule Y2019.D7Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2019, 7, async: true do
    test "part 1 with input" do
      assert Y2019.D7.p1(input_string()) == 21000
    end

    test "part 2 with input" do
      assert Y2019.D7.p2(input_string()) == 61379886
    end
  end
end
