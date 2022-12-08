defmodule D01Test do
  use ExUnit.Case
  doctest D01

  test "day 01 - part 1 - example" do
    input =
      """
      1000
      2000
      3000

      4000

      5000
      6000

      7000
      8000
      9000

      10000
      """
    assert D01.part1(input) == 24000
  end

  test "day 01 - part 2 - example" do
    input =
      """
      1000
      2000
      3000

      4000

      5000
      6000

      7000
      8000
      9000

      10000
      """
    assert D01.part2(input) == 45000
  end
end
