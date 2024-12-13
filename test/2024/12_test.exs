import AOC

aoc_test 2024, 12, async: true do
  def get_example_input() do
    """
    RRRRIICCFF
    RRRRIICCCF
    VVRRRCCFFF
    VVRCCCJFFF
    VVVVCJJCFE
    VVIVCCJJEE
    VVIIICJJEE
    MIIIIIJJEE
    MIIISIJEEE
    MMMISSJEEE
    """
  end
  test "p1e" do
    assert Y2024.D12.p1(get_example_input()) == 1930
  end

  test "p1i" do
    assert Y2024.D12.p1(input_string()) == 1437300
  end

  test "p2e" do
    assert Y2024.D12.p2(get_example_input()) == 1206
  end

  test "p2i" do
    assert Y2024.D12.p2(input_string()) == 849332
  end
end
