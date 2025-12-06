defmodule Y2022.D15Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2022, 15, async: true do
    test "part 1 with input" do
      assert Y2022.D15.p1(input_string()) == 5256611
    end

    test "part 2 with input" do
      assert Y2022.D15.p2(input_string()) == 13337919186981
    end
  end
end
