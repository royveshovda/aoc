import AOC

aoc_test 2021, 20, async: true do
  # Days 19-25 were not implemented in original livebooks
  # Answers will be verified after solving

  @tag :skip
  test "part 1 input" do
    result = Y2021.D20.p1(input_string())
    assert is_integer(result)
  end

  @tag :skip
  test "part 2 input" do
    result = Y2021.D20.p2(input_string())
    assert is_integer(result)
  end
end
