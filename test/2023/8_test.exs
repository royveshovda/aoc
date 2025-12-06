defmodule Y2023.D8Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2023, 8, async: true do
    test "part 1 with input" do
      assert Y2023.D8.p1(input_string()) == 17287
    end

    test "part 2 with input" do
      assert Y2023.D8.p2(input_string()) == 18625484023687
    end
  end
end
