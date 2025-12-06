import AOC

aoc_test 2018, 13, async: true do
  test "part 1 input" do
    assert Y2018.D13.p1(input_string()) == "32,8"
  end

  test "part 2 input" do
    assert Y2018.D13.p2(input_string()) == "38,38"
  end
end
