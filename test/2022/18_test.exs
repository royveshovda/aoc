defmodule Y2022.D18Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2022, 18, async: true do
    test "part 1 with input" do
      assert Y2022.D18.p1(input_string()) == 4456
    end

    test "part 2 with input" do
      assert Y2022.D18.p2(input_string()) == 2510
    end
  end
end
