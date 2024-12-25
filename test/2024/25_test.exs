import AOC

aoc_test 2024, 25, async: true do
  test "p1e" do
    assert Y2024.D25.p1(example_string()) == 3
  end

  test "p1i" do
    assert Y2024.D25.p1(input_string()) == 3344
  end
end
