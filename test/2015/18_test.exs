import AOC

aoc_test 2015, 18, async: true do
  test "part 1 input" do
    assert Y2015.D18.p1(input_string()) == 1061
  end

  test "part 2 input" do
    assert Y2015.D18.p2(input_string()) == 1006
  end
end
