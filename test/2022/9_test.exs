defmodule Y2022.D9Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2022, 9, async: true do
    test "part 1 with input" do
      assert Y2022.D9.p1(input_string()) == 6284
    end

    test "part 2 with input" do
      assert Y2022.D9.p2(input_string()) == 2661
    end
  end
end
