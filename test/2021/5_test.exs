import AOC

aoc_test 2021, 5, async: true do
  @example "0,9 -> 5,9\n8,0 -> 0,8\n9,4 -> 3,4\n2,2 -> 2,1\n7,0 -> 7,4\n6,4 -> 2,0\n0,9 -> 2,9\n3,4 -> 1,4\n0,0 -> 8,8\n5,5 -> 8,2"

  test "part 1 example" do
    assert Y2021.D5.p1(@example) == 5
  end

  test "part 1 input" do
    assert Y2021.D5.p1(input_string()) == 6267
  end

  test "part 2 example" do
    assert Y2021.D5.p2(@example) == 12
  end

  test "part 2 input" do
    assert Y2021.D5.p2(input_string()) == 20196
  end
end
