import AOC

aoc_test 2018, 16, async: true do
  test "part 1 input" do
    assert Y2018.D16.p1(input_string()) == 640
  end

  test "part 2 input" do
    assert Y2018.D16.p2(input_string()) == 472
  end
end
