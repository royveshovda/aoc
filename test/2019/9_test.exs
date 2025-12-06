defmodule Y2019.D9Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2019, 9, async: true do
    test "part 1 with input" do
      assert Y2019.D9.p1(input_string()) == 3335138414
    end

    test "part 2 with input" do
      assert Y2019.D9.p2(input_string()) == 49122
    end
  end
end
