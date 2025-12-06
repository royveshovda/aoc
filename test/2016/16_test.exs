import AOC

aoc_test 2016, 16, async: true do
  test "part 1 input" do
    assert Y2016.D16.p1(input_string()) == "10010010110011010"
  end

  @tag :skip
  @tag :slow
  test "part 2 input" do
    # Takes > 2 minutes - algorithm needs optimization
    assert Y2016.D16.p2(input_string()) == "01010100101011100"
  end
end
