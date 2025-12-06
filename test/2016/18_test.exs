import AOC

aoc_test 2016, 18, async: true do
  test "part 1 input" do
    assert Y2016.D18.p1(input_string()) == 1951
  end

  @tag :skip
  @tag :slow
  test "part 2 input" do
    # Takes > 2 minutes - algorithm needs optimization
    assert Y2016.D18.p2(input_string()) == 20_002_936
  end
end
