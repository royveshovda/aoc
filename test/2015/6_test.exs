import AOC

aoc_test 2015, 6, async: true do
  test "part 1 input" do
    assert Y2015.D6.p1(input_string()) == 377_891
  end

  @tag timeout: :infinity
  test "part 2 input" do
    assert Y2015.D6.p2(input_string()) == 14_110_788
  end
end
