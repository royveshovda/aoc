import AOC

aoc_test 2024, 22, async: true do
  test "p1e" do
    input =
      """
      1
      10
      100
      2024
      """
    assert Y2024.D22.p1(input) == 37_327_623
  end

  test "p1i" do
    assert Y2024.D22.p1(input_string()) == 16_953_639_210
  end

  test "p2e" do
    input =
      """
      1
      2
      3
      2024
      """
    assert Y2024.D22.p2(input) == 23
  end

  test "p2i" do
    assert Y2024.D22.p2(input_string()) == 1863
  end
end
