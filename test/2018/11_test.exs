import AOC

aoc_test 2018, 11, async: true do
  test "part 1 input" do
    assert Y2018.D11.p1(input_string()) == "21,53"
  end

  test "part 2 input" do
    assert Y2018.D11.p2(input_string()) == "233,250,12"
  end
end
