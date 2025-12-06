import AOC

aoc_test 2016, 6, async: true do
  test "part 1 input" do
    assert Y2016.D6.p1(input_string()) == "cyxeoccr"
  end

  test "part 2 input" do
    assert Y2016.D6.p2(input_string()) == "batwpask"
  end
end
