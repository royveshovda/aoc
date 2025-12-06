defmodule Y2023.D5Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2023, 5, async: true do
    test "part 1 with input" do
      assert Y2023.D5.p1(input_string()) == 313045984
    end

    test "part 2 with input" do
      assert Y2023.D5.p2(input_string()) == 20283860
    end
  end
end
