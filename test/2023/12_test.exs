defmodule Y2023.D12Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2023, 12, async: true do
    test "part 1 with input" do
      assert Y2023.D12.p1(input_string()) == 8180
    end

    test "part 2 with input" do
      assert Y2023.D12.p2(input_string()) == 620189727003627
    end
  end
end
