import AOC

aoc_test 2024, 1, async: true do
  test "p1e" do
    assert Y2024.D1.p1(example_string()) == 11
  end

  test "p1i" do
    assert Y2024.D1.p1(input_string()) == 1_651_298
  end

  test "p2e" do
    assert Y2024.D1.p2(example_string()) == 31
  end

  test "p2i" do
    assert Y2024.D1.p2(input_string()) == 21_306_195
  end
end
