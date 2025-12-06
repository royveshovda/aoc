import AOC

aoc_test 2018, 14, async: true do
  test "part 1 input" do
    assert Y2018.D14.p1(input_string()) == "1221283494"
  end

  test "part 2 input" do
    assert Y2018.D14.p2(input_string()) == 20_261_485
  end
end
