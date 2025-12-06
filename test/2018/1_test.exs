import AOC

aoc_test 2018, 1, async: true do
  test "part 1 input" do
    assert Y2018.D1.p1(input_string()) == 439
  end

  test "part 2 input" do
    assert Y2018.D1.p2(input_string()) == 124_645
  end
end
