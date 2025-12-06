import AOC

aoc_test 2021, 12, async: true do
  @example "start-A\nstart-b\nA-c\nA-b\nb-d\nA-end\nb-end"

  test "part 1 example" do
    assert Y2021.D12.p1(@example) == 10
  end

  test "part 1 input" do
    assert Y2021.D12.p1(input_string()) == 3779
  end

  test "part 2 example" do
    assert Y2021.D12.p2(@example) == 36
  end

  test "part 2 input" do
    assert Y2021.D12.p2(input_string()) == 96988
  end
end
