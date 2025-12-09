import AOC

aoc_test 2025, 9, async: true do
  test "part 1 with input" do
    assert Y2025.D9.p1(input_string()) == 4_759_531_084
  end

  test "part 2 with input" do
    assert Y2025.D9.p2(input_string()) == 1_539_238_860
  end
end
