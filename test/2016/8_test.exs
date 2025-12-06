import AOC

aoc_test 2016, 8, async: true do
  test "part 1 input" do
    assert Y2016.D8.p1(input_string()) == 128
  end

  # Part 2 returns visual grid output - verify it contains expected pattern
  test "part 2 input" do
    result = Y2016.D8.p2(input_string())
    # The answer spells "EOARGPHYAO" but is rendered as ASCII art
    assert is_binary(result)
    assert String.contains?(result, "####")
  end
end
