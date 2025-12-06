import AOC

aoc_test 2015, 23, async: true do
  test "part 1 input" do
    assert Y2015.D23.p1(input_string()) == 307
  end

  test "part 2 input" do
    assert Y2015.D23.p2(input_string()) == 160
  end
end
