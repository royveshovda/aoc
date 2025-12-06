defmodule Y2025.D3Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2025, 3, async: true do
    test "part 1 with input" do
      assert Y2025.D3.p1(input_string()) == 17432
    end

    test "part 2 with input" do
      assert Y2025.D3.p2(input_string()) == 173065202451341
    end
  end
end
