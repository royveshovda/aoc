import AOC

aoc_test 2018, 7, async: true do
  @tag :skip
  test "part 1 input" do
    assert Y2018.D7.p1(input_string()) == "IOFSJQDUWAPXELNVYZMHTBCRGK"
  end

  @tag :skip
  test "part 2 input" do
    assert Y2018.D7.p2(input_string()) == 931
  end
end
