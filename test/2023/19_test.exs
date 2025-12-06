defmodule Y2023.D19Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2023, 19, async: true do
    test "part 1 with input" do
      assert Y2023.D19.p1(input_string()) == 434147
    end

    test "part 2 with input" do
      assert Y2023.D19.p2(input_string()) == 136146366355609
    end
  end
end
