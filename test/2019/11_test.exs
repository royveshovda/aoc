defmodule Y2019.D11Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2019, 11, async: true do
    test "part 1 with input" do
      assert Y2019.D11.p1(input_string()) == 1894
    end

    test "part 2 with input" do
      # Part 2 renders visual ASCII art that spells JKZLZJBH
      result = Y2019.D11.p2(input_string())
      # Check it returns a multi-line grid (visual output)
      assert is_binary(result)
      assert String.contains?(result, "\n")
      assert String.contains?(result, "#")
    end
  end
end
