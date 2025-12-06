import AOC

aoc_test 2018, 17, async: true do
  test "part 1 input" do
    assert Y2018.D17.p1(input_string()) == 41027
  end

  test "part 2 input" do
    assert Y2018.D17.p2(input_string()) == 34214
  end
end
