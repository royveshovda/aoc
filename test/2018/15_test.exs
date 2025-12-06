import AOC

aoc_test 2018, 15, async: true do
  test "part 1 input" do
    assert Y2018.D15.p1(input_string()) == 198_531
  end

  test "part 2 input" do
    assert Y2018.D15.p2(input_string()) == 90420
  end
end
