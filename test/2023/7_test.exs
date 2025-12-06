defmodule Y2023.D7Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2023, 7, async: true do
    test "part 1 with input" do
      assert Y2023.D7.p1(input_string()) == 246912307
    end

    test "part 2 with input" do
      assert Y2023.D7.p2(input_string()) == 246894760
    end
  end
end
