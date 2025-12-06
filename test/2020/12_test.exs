defmodule Y2020.D12Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2020, 12, async: true do
    test "part 1 with input" do
      assert Y2020.D12.p1(input_string()) == 2458
    end

    test "part 2 with input" do
      assert Y2020.D12.p2(input_string()) == 145117
    end
  end
end
