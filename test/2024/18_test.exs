import AOC

aoc_test 2024, 18, async: true do
  test "p1e" do
    assert Y2024.D18.p1({example_string(), 12, 6}) == 22
  end

  test "p1i" do
    assert Y2024.D18.p1({input_string(), 1024, 70}) == 250
  end

  test "p2e" do
    assert Y2024.D18.p2({example_string(), 12, 6}) == "6,1"
  end

  test "p2i" do
    assert Y2024.D18.p2({input_string(), 1024, 70}) == "56,8"
  end
end
