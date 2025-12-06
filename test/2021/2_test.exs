import AOC

aoc_test 2021, 2, async: true do
  @example "forward 5\ndown 5\nforward 8\nup 3\ndown 8\nforward 2"

  test "part 1 example" do
    assert Y2021.D2.p1(@example) == 150
  end

  test "part 1 input" do
    assert Y2021.D2.p1(input_string()) == 2_120_749
  end

  test "part 2 example" do
    assert Y2021.D2.p2(@example) == 900
  end

  test "part 2 input" do
    assert Y2021.D2.p2(input_string()) == 2_138_382_217
  end
end
