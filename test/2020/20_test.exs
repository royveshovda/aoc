defmodule Y2020.D20Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2020, 20, async: true do
    test "part 1 with input" do
      assert Y2020.D20.p1(input_string()) == 27803643063307
    end

    test "part 2 with input" do
      assert Y2020.D20.p2(input_string()) == 1644
    end
  end
end
