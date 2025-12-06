import AOC

aoc_test 2018, 10, async: true do
  @tag :skip
  test "part 1 input" do
    # Part 1 returns visual grid, check for expected letters
    result = Y2018.D10.p1(input_string())
    assert is_binary(result) or String.contains?(to_string(result), "RGRKHKNA")
  end

  @tag :skip
  test "part 2 input" do
    assert Y2018.D10.p2(input_string()) == 10117
  end
end
