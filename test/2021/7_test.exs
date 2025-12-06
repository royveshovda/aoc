import AOC

aoc_test 2021, 7, async: true do
  @example "16,1,2,0,4,2,7,1,2,14"

  test "part 1 example" do
    assert Y2021.D7.p1(@example) == 37
  end

  test "part 1 input" do
    assert Y2021.D7.p1(input_string()) == 343_468
  end

  test "part 2 example" do
    assert Y2021.D7.p2(@example) == 168
  end

  test "part 2 input" do
    assert Y2021.D7.p2(input_string()) == 96_086_265
  end
end
