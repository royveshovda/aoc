import AOC

aoc_test 2024, 2, async: true do
  test "p1e" do
    assert Y2024.D2.p1(example_string()) == 2
  end

  test "p1i" do
    assert Y2024.D2.p1(input_string()) == 639
  end

  test "p2e" do
    assert Y2024.D2.p2(example_string()) == 4
  end

  test "p2i" do
    assert Y2024.D2.p2(input_string()) == 674
  end
end
