defmodule Y2025.D2Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2025, 2, async: true do
    test "part 1 with input" do
      assert Y2025.D2.p1(input_string()) == 19128774598
    end

    test "part 2 with input" do
      assert Y2025.D2.p2(input_string()) == 21932258645
    end
  end
end
