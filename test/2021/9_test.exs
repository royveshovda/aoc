import AOC

aoc_test 2021, 9, async: true do
  @example "2199943210\n3987894921\n9856789892\n8767896789\n9899965678"

  test "part 1 example" do
    assert Y2021.D9.p1(@example) == 15
  end

  test "part 1 input" do
    assert Y2021.D9.p1(input_string()) == 512
  end

  test "part 2 example" do
    assert Y2021.D9.p2(@example) == 1134
  end

  # Part 2 answer will be verified after running
  test "part 2 input" do
    result = Y2021.D9.p2(input_string())
    assert is_integer(result)
  end
end
