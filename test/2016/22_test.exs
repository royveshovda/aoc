import AOC

aoc_test 2016, 22, async: true do
  test "part 1 input" do
    assert Y2016.D22.p1(input_string()) == 888
  end

  test "part 2 input" do
    assert Y2016.D22.p2(input_string()) == 236
  end
end
