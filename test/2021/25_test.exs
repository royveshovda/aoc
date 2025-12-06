import AOC

aoc_test 2021, 25, async: true do
  @example "v...>>.vv>\n.vv>>.vv..\n>>.>v>...v\n>>v>>.>.v.\nv>v.vv.v..\n>.>>..v...\n.vv..>.>v.\nv.v..>>v.v\n....v..v.>"

  test "part 1 example" do
    assert Y2021.D25.p1(@example) == 58
  end

  # Skip input tests until we know expected values
  @tag :skip
  test "part 1 input" do
    result = Y2021.D25.p1(input_string())
    assert is_integer(result)
  end

  # Day 25 Part 2 is automatic (no puzzle)
  test "part 2" do
    assert Y2021.D25.p2("") == "⭐"
  end
end
