defmodule Y2022.D25Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2022, 25, async: true do
    test "part 1 with input" do
      assert Y2022.D25.p1(input_string()) == "2-=0-=-2=111=220=100"
    end
  end
end
