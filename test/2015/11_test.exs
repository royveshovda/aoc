import AOC

aoc_test 2015, 11, async: true do
  test "part 1 input" do
    assert Y2015.D11.p1(input_string()) == "hxbxxyzz"
  end

  test "part 2 input" do
    assert Y2015.D11.p2(input_string()) == "hxcaabcc"
  end
end
