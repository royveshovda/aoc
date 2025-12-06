import AOC

aoc_test 2021, 21, async: true do
  @example "Player 1 starting position: 4\nPlayer 2 starting position: 8"

  test "part 1 example" do
    assert Y2021.D21.p1(@example) == 739_785
  end

  # Skip input tests until we know expected values
  @tag :skip
  test "part 1 input" do
    result = Y2021.D21.p1(input_string())
    assert is_integer(result)
  end

  test "part 2 example" do
    assert Y2021.D21.p2(@example) == 444_356_092_776_315
  end

  @tag :skip
  test "part 2 input" do
    result = Y2021.D21.p2(input_string())
    assert is_integer(result)
  end
end
