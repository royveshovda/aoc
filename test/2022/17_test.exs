defmodule Y2022.D17Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2022, 17, async: true do
    test "part 1 with input" do
      assert Y2022.D17.p1(input_string()) == 3177
    end

    test "part 2 with input" do
      assert Y2022.D17.p2(input_string()) == 1565517241382
    end
  end
end
