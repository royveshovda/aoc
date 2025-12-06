defmodule Y2019.D1Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2019, 1, async: true do
    test "part 1 with input" do
      assert Y2019.D1.p1(input_string()) == 3550236
    end

    test "part 2 with input" do
      assert Y2019.D1.p2(input_string()) == 5322455
    end
  end
end
