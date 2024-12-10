import AOC

aoc_test 2024, 9, async: true do
  test "p1e" do
    assert Y2024.D9.p1(example_string()) == 1928
  end

  @tag timeout: :infinity
  test "p1i" do
    assert Y2024.D9.p1(input_string()) == 6_519_155_389_266
  end

  test "p2e" do
    assert Y2024.D9.p2(example_string()) == 2858
  end

  @tag timeout: :infinity
  test "p2i" do
    assert Y2024.D9.p2(input_string()) == 6547228115826
  end
end
