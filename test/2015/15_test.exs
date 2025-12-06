import AOC

aoc_test 2015, 15, async: true do
  test "part 1 input" do
    assert Y2015.D15.p1(input_string()) == 21_367_368
  end

  test "part 2 input" do
    assert Y2015.D15.p2(input_string()) == 1_766_400
  end
end
