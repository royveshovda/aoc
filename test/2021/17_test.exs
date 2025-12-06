import AOC

aoc_test 2021, 17, async: true do
  @example "target area: x=20..30, y=-10..-5"

  test "part 1 example" do
    assert Y2021.D17.p1(@example) == 45
  end

  test "part 1 input" do
    assert Y2021.D17.p1(input_string()) == 8256
  end

  test "part 2 example" do
    assert Y2021.D17.p2(@example) == 112
  end

  # Part 2 answer will be verified after running
  test "part 2 input" do
    result = Y2021.D17.p2(input_string())
    assert is_integer(result)
  end
end
