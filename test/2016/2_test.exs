import AOC

aoc_test 2016, 2, async: true do
  test "part 1 input" do
    assert Y2016.D2.p1(input_string()) == "18843"
  end

  test "part 2 input" do
    assert Y2016.D2.p2(input_string()) == "67BB9"
  end
end
