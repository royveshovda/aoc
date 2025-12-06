import AOC

aoc_test 2018, 19, async: true do
  test "part 1 input" do
    assert Y2018.D19.p1(input_string()) == 1120
  end

  test "part 2 input" do
    assert Y2018.D19.p2(input_string()) == 12_768_192
  end
end
