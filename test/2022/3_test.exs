defmodule Y2022.D3Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2022, 3, async: true do
    test "part 1 with input" do
      assert Y2022.D3.p1(input_string()) == 8123
    end

    test "part 2 with input" do
      assert Y2022.D3.p2(input_string()) == 2620
    end
  end
end
