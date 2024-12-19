import AOC

aoc_test 2024, 19, async: true do
  test "p1e" do
    assert Y2024.D19.p1(example_string()) == 6
  end

  test "p1i" do
    assert Y2024.D19.p1(input_string()) == 327
  end

  test "p2e" do
    assert Y2024.D19.p2(example_string()) == 16
  end

  test "p2i" do
    assert Y2024.D19.p2(input_string()) == 772_696_486_795_255
  end
end
