import AOC

aoc_test 2015, 20, async: true do
  test "part 1 input" do
    assert Y2015.D20.p1(input_string()) == 786_240
  end

  test "part 2 input" do
    assert Y2015.D20.p2(input_string()) == 831_600
  end
end
