defmodule Y2020.D3Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2020, 3, async: true do
    test "part 1 with input" do
      assert Y2020.D3.p1(input_string()) == 242
    end

    test "part 2 with input" do
      assert Y2020.D3.p2(input_string()) == 2265549792
    end
  end
end
