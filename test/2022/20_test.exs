defmodule Y2022.D20Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2022, 20, async: true do
    test "part 1 with input" do
      assert Y2022.D20.p1(input_string()) == 9687
    end

    test "part 2 with input" do
      assert Y2022.D20.p2(input_string()) == 1338310513297
    end
  end
end
