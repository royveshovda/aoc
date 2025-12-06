import AOC

aoc_test 2015, 9, async: true do
  test "part 1 input" do
    assert Y2015.D9.p1(input_string()) == 141
  end

  test "part 2 input" do
    assert Y2015.D9.p2(input_string()) == 736
  end
end
