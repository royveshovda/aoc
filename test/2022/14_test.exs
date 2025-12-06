defmodule Y2022.D14Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2022, 14, async: true do
    test "part 1 with input" do
      assert Y2022.D14.p1(input_string()) == 817
    end

    test "part 2 with input" do
      assert Y2022.D14.p2(input_string()) == 23416
    end
  end
end
