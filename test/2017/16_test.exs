import AOC

aoc_test 2017, 16, async: true do
  test "part 1 input" do
    assert Y2017.D16.p1(input_string()) == "fgmobeaijhdpkcln"
  end

  test "part 2 input" do
    assert Y2017.D16.p2(input_string()) == "lgmkacfjbopednhi"
  end
end
