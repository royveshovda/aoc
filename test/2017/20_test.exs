import AOC

aoc_test 2017, 20, async: true do
  test "part 1 input" do
    assert Y2017.D20.p1(input_string()) == 243
  end

  test "part 2 input" do
    assert Y2017.D20.p2(input_string()) == 648
  end
end
