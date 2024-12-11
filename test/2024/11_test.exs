import AOC

aoc_test 2024, 11, async: true do
  def get_example_input() do
    """
    125 17
    """
  end
  test "p1e" do
    assert Y2024.D11.p1(get_example_input()) == 55312
  end

  test "p1i" do
    assert Y2024.D11.p1(input_string()) == 1
  end

  # test "p2e" do
  #   assert Y2024.D11.p2(example_string()) == 1
  # end

  @tag timeout: :infinity
  test "p2i" do
    assert Y2024.D11.p2(input_string()) == 1
  end
end
