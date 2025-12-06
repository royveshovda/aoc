import AOC

aoc_test 2017, 23, async: true do
  test "part 1 input" do
    assert Y2017.D23.p1(input_string()) == 5929
  end

  test "part 2 input" do
    assert Y2017.D23.p2(input_string()) == 907
  end
end
