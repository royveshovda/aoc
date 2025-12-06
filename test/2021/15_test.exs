import AOC

aoc_test 2021, 15, async: true do
  @example "1163751742\n1381373672\n2136511328\n3694931569\n7463417111\n1319128137\n1359912421\n3125421639\n1293138521\n2311944581"

  test "part 1 example" do
    assert Y2021.D15.p1(@example) == 40
  end

  test "part 1 input" do
    assert Y2021.D15.p1(input_string()) == 602
  end

  test "part 2 example" do
    assert Y2021.D15.p2(@example) == 315
  end

  @tag timeout: :infinity
  test "part 2 input" do
    assert Y2021.D15.p2(input_string()) == 2935
  end
end
