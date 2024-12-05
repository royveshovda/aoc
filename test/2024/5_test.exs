import AOC

aoc_test 2024, 5, async: true do
  test "p1e" do
    assert Y2024.D5.p1(example_string()) == 143
  end

  test "p1i" do
    assert Y2024.D5.p1(input_string()) == 5208
  end

  test "p2e" do
    assert Y2024.D5.p2(example_string()) == 123
  end

  # test "p2i" do
  #   assert Y2024.D5.p2(input_string()) == 0
  # end
end
