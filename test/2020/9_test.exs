defmodule Y2020.D9Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2020, 9, async: true do
    test "part 1 with input" do
      assert Y2020.D9.p1(input_string()) == 85848519
    end

    test "part 2 with input" do
      assert Y2020.D9.p2(input_string()) == 13414198
    end
  end
end
