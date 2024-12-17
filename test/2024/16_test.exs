import AOC

aoc_test 2024, 16, async: true do
  test "p1e" do
    assert Y2024.D16.p1(example_string()) == 7036
  end

  test "p1i" do
    assert Y2024.D16.p1(input_string()) == 94436
  end

  test "p2e" do
    assert Y2024.D16.p2(example_string()) == 45
  end

  test "p2i" do
    assert Y2024.D16.p2(input_string()) == 481
  end
end
