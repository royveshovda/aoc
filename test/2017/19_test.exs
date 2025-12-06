import AOC

aoc_test 2017, 19, async: true do
  test "part 1 input" do
    assert Y2017.D19.p1(input_string()) == "GINOWKYXH"
  end

  test "part 2 input" do
    assert Y2017.D19.p2(input_string()) == 16636
  end
end
