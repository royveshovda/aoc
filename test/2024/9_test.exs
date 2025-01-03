import AOC

aoc_test 2024, 9, async: true do
  test "p1e" do
    assert Y2024.D9.p1(example_string()) == 1928
  end

  test "p1i" do
    assert Y2024.D9.p1(input_string()) == 6_519_155_389_266
  end

  test "p2e" do
    assert Y2024.D9.p2(example_string()) == 2858
  end

  test "p2i" do
    assert Y2024.D9.p2(input_string()) == 6_547_228_115_826
  end
end
