defmodule Y2020.D2Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2020, 2, async: true do
    test "part 1 with input" do
      assert Y2020.D2.p1(input_string()) == 477
    end

    test "part 2 with input" do
      assert Y2020.D2.p2(input_string()) == 686
    end
  end
end
