import AOC

aoc_test 2024, 6, async: true do
  test "p1e" do
    assert Y2024.D6.p1(example_string()) == 41
  end

  test "p1i" do
    assert Y2024.D6.p1(input_string()) == 4711
  end

  test "p2e" do
    assert Y2024.D6.p2(example_string()) == 6
  end

  test "p2i" do
    assert Y2024.D6.p2(input_string()) == 1562
  end
end
