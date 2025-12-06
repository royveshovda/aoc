defmodule Y2023.D6Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2023, 6, async: true do
    test "part 1 with input" do
      assert Y2023.D6.p1(input_string()) == 4568778
    end

    test "part 2 with input" do
      assert Y2023.D6.p2(input_string()) == 28973936
    end
  end
end
