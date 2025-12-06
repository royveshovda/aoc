import AOC

aoc_test 2016, 17, async: true do
  test "part 1 input" do
    assert Y2016.D17.p1(input_string()) == "RDDRLDRURD"
  end

  test "part 2 input" do
    assert Y2016.D17.p2(input_string()) == 448
  end
end
