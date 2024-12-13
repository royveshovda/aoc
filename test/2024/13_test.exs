import AOC

aoc_test 2024, 13, async: true do
  test "p1e" do
    assert Y2024.D13.p1(example_string()) == 480
  end

  test "p1i" do
    assert Y2024.D13.p1(input_string()) == 37_686
  end

  test "p2e" do
    assert Y2024.D13.p2(example_string()) == 875_318_608_908
  end

  test "p2i" do
    assert Y2024.D13.p2(input_string()) == 77_204_516_023_437
  end
end
