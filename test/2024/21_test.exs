import AOC

aoc_test 2024, 21, async: true do
  def get_example() do
    """
    029A
    980A
    179A
    456A
    379A
    """
  end

  test "p1e" do
    assert Y2024.D21.p1(get_example()) == 126_384
  end

  test "p1i" do
    assert Y2024.D21.p1(input_string()) == 164_960
  end

  test "p2e" do

    assert Y2024.D21.p2(get_example()) == 154_115_708_116_294
  end

  test "p2i" do
    assert Y2024.D21.p2(input_string()) == 205_620_604_017_764
  end
end
