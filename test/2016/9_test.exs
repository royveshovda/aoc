import AOC

aoc_test 2016, 9, async: true do
  test "part 1 input" do
    assert Y2016.D9.p1(input_string()) == 98135
  end

  test "part 2 input" do
    assert Y2016.D9.p2(input_string()) == 10_964_557_606
  end
end
