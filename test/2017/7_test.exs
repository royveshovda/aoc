import AOC

aoc_test 2017, 7, async: true do
  test "part 1 input" do
    assert Y2017.D7.p1(input_string()) == "ykpsek"
  end

  test "part 2 input" do
    assert Y2017.D7.p2(input_string()) == 1060
  end
end
