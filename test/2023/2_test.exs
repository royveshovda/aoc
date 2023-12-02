import AOC

aoc_test 2023, 2, async: true do

  test "p1e" do
    assert Y2023.D2.p1(example_string()) == 8
  end

  test "p1i" do
    assert Y2023.D2.p1(input_string()) == 2348
  end

  test "p2e" do
    assert Y2023.D2.p2(example_string()) == 2286
  end

  test "p2i" do
    assert Y2023.D2.p2(input_string()) == 76008
  end
end
