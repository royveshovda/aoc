import AOC

aoc_test 2017, 10, async: true do
  test "part 1 input" do
    assert Y2017.D10.p1(input_string()) == 11413
  end

  test "part 2 input" do
    assert Y2017.D10.p2(input_string()) == "7adfd64c2a03a4968cf708d1b7fd418d"
  end
end
