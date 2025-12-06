defmodule Y2023.D20Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2023, 20, async: true do
    test "part 1 with input" do
      assert Y2023.D20.p1(input_string()) == 747304011
    end

    test "part 2 with input" do
      assert Y2023.D20.p2(input_string()) == 220366255099387
    end
  end
end
