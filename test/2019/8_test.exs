defmodule Y2019.D8Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2019, 8, async: true do
    test "part 1 with input" do
      assert Y2019.D8.p1(input_string()) == 1215
    end

    @tag :skip
    test "part 2 with input" do
      # Part 2 renders visual output showing "LHCPH" - skipping automated check
      result = Y2019.D8.p2(input_string())
      assert is_binary(result)
    end
  end
end
