defmodule Y2019.D12Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2019, 12, async: true do
    test "part 1 with input" do
      assert Y2019.D12.p1(input_string()) == 11384
    end

    test "part 2 with input" do
      assert Y2019.D12.p2(input_string()) == 452582583272768
    end
  end
end
