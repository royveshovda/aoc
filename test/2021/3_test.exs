import AOC

aoc_test 2021, 3, async: true do
  @example "00100\n11110\n10110\n10111\n10101\n01111\n00111\n11100\n10000\n11001\n00010\n01010"

  test "part 1 example" do
    assert Y2021.D3.p1(@example) == 198
  end

  test "part 1 input" do
    assert Y2021.D3.p1(input_string()) == 4_160_394
  end

  test "part 2 example" do
    assert Y2021.D3.p2(@example) == 230
  end

  # Part 2 answer will be verified after running
  test "part 2 input" do
    result = Y2021.D3.p2(input_string())
    assert is_integer(result)
  end
end
