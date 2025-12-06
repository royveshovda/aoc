import AOC

aoc_test 2016, 5, async: true do
  test "part 1 input" do
    assert Y2016.D5.p1(input_string()) == "d4cd2ee1"
  end

  test "part 2 input" do
    assert Y2016.D5.p2(input_string()) == "f2c730e5"
  end
end
