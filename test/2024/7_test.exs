import AOC

aoc_test 2024, 7, async: true do
  test "p1e" do
    assert Y2024.D7.p1(example_string()) == 3749
  end

  test "p1i" do
    assert Y2024.D7.p1(input_string()) == 5_512_534_574_980
  end

  test "p2e" do
    assert Y2024.D7.p2(example_string()) == 11_387
  end

  test "p2i" do
    assert Y2024.D7.p2(input_string()) == 328_790_210_468_594
  end
end
