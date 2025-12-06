import AOC

aoc_test 2021, 23, async: true do
  # Days 19-25 were not implemented in original livebooks
  # Answers will be verified after solving

  @tag :skip
  @tag timeout: :infinity
  test "part 1 input" do
    result = Y2021.D23.p1(input_string())
    assert is_integer(result)
  end

  @tag :skip
  @tag timeout: :infinity
  test "part 2 input" do
    result = Y2021.D23.p2(input_string())
    assert is_integer(result)
  end
end
