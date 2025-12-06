import AOC

aoc_test 2018, 18, async: true do
  test "part 1 input" do
    assert Y2018.D18.p1(input_string()) == 589_931
  end

  test "part 2 input" do
    assert Y2018.D18.p2(input_string()) == 222_332
  end
end
