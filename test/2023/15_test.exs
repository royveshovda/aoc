defmodule Y2023.D15Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2023, 15, async: true do
    test "part 1 with input" do
      assert Y2023.D15.p1(input_string()) == 505379
    end

    test "part 2 with input" do
      assert Y2023.D15.p2(input_string()) == 263211
    end
  end
end
