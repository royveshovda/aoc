import AOC

aoc_test 2017, 13, async: true do
  test "part 1 input" do
    assert Y2017.D13.p1(input_string()) == 1300
  end

  test "part 2 input" do
    assert Y2017.D13.p2(input_string()) == 3_870_382
  end
end
