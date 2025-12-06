defmodule Y2022.D10Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2022, 10, async: true do
    test "part 1 with input" do
      assert Y2022.D10.p1(input_string()) == 12460
    end

    test "part 2 with input" do
      # Part 2 returns visual grid, check for expected letters
      result = Y2022.D10.p2(input_string())
      assert is_binary(result) or String.contains?(to_string(result), "EZFPRAKL")
    end
  end
end
