import AOC

aoc_test 2021, 13, async: true do
  @example "6,10\n0,14\n9,10\n0,3\n10,4\n4,11\n6,0\n6,12\n4,1\n0,13\n10,12\n3,4\n3,0\n8,4\n1,10\n2,14\n8,10\n9,0\n\nfold along y=7\nfold along x=5"

  test "part 1 example" do
    assert Y2021.D13.p1(@example) == 17
  end

  test "part 1 input" do
    assert Y2021.D13.p1(input_string()) == 770
  end

  # Part 2 renders "EPUELPBR" as ASCII art
  test "part 2 input" do
    result = Y2021.D13.p2(input_string())
    assert is_binary(result)
  end
end
