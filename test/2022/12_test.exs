defmodule Y2022.D12Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2022, 12, async: true do
    test "part 1 with input" do
      assert Y2022.D12.p1(input_string()) == 361
    end

    test "part 2 with input" do
      assert Y2022.D12.p2(input_string()) == 354
    end
  end
end
