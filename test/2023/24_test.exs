defmodule Y2023.D24Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2023, 24, async: true do
    test "part 1 with input" do
      assert Y2023.D24.p1(input_string(), 200_000_000_000_000, 400_000_000_000_000) == 20847
    end

    test "part 2 with input" do
      assert Y2023.D24.p2(input_string()) == 908621716620524
    end
  end
end
