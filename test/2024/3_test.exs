import AOC

aoc_test 2024, 3, async: true do
  def get_example_string() do
    """
    xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
    """
  end
  test "p1e" do
    assert Y2024.D3.p1(get_example_string()) == 161
  end

  test "p1i" do
    assert Y2024.D3.p1(input_string()) == 161_085_926
  end

  test "p2e" do
    assert Y2024.D3.p2(get_example_string()) == 48
  end

  test "p2i" do
    assert Y2024.D3.p2(input_string()) == 82_045_421
  end
end
