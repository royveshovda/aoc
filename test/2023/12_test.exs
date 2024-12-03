import AOC

aoc_test 2023, 12, async: true do
  test "pattern verificatioin on corrent pattern" do
    assert correct_pattern?([".", "#", "#", "#", ".", "#", "#", ".", "#", ".", ".", "."], [3, 2, 1])
  end

  test "pattern verificatioin on wrong pattern" do
    assert !correct_pattern?([".", "#", "#", ".", ".", "#", "#", ".", "#", ".", ".", "."], [3, 2, 2])
  end
end
