defmodule Y2023.D3Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2023, 3, async: true do
    test "part 1 with input" do
      assert Y2023.D3.p1(input_string()) == 527364
    end

    test "part 2 with input" do
      assert Y2023.D3.p2(input_string()) == 79026871
    end
  end
end
