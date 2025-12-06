import AOC

aoc_test 2021, 1, async: true do
  @example "199\n200\n208\n210\n200\n207\n240\n269\n260\n263"

  test "part 1 example" do
    assert Y2021.D1.p1(@example) == 7
  end

  test "part 1 input" do
    assert Y2021.D1.p1(input_string()) == 1298
  end

  test "part 2 example" do
    assert Y2021.D1.p2(@example) == 5
  end

  test "part 2 input" do
    assert Y2021.D1.p2(input_string()) == 1248
  end
end
