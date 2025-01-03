import AOC

aoc_test 2024, 14, async: true do
  test "p1e" do
    assert Y2024.D14.p1({example_string(), 11, 7}) == 12
  end

  test "p1i" do
    assert Y2024.D14.p1({input_string(), 101, 103}) == 218_965_032
  end

  # test "p2e" do
  #   assert Y2024.D14.p2(example_string()) == 1
  # end

  test "p2i" do
    assert Y2024.D14.p2({input_string(), 101, 103}) == 7037
  end
end
