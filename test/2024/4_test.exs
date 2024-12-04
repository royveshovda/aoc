import AOC

aoc_test 2024, 4, async: true do
  test "p1e" do
    assert Y2024.D4.p1(example_string()) == 18
  end

  test "p1i" do
    assert Y2024.D4.p1(input_string()) == 2685
  end

  test "p2e" do
    assert Y2024.D4.p2(example_string()) == 9
  end

  test "p2i" do
    assert Y2024.D4.p2(input_string()) == 2048
  end
end
