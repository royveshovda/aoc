import AOC

aoc_test 2024, 10, async: true do

  def get_example_input_1() do
    """
    4320234
    5441987
    9992999
    6543456
    7911117
    8111118
    9111119
    """
  end

  def get_example_input_2() do
    """
    1190229
    3331398
    4442447
    6543456
    7651987
    8761111
    9871111
    """
  end

  def get_example_input_3() do
    """
    89010123
    78121874
    87430965
    96549874
    45678903
    32019012
    01329801
    10456732
    """
  end
  test "p1e" do
    assert Y2024.D10.p1(get_example_input_1()) == 2
    assert Y2024.D10.p1(get_example_input_2()) == 4
    assert Y2024.D10.p1(get_example_input_3()) == 36
  end

  test "p1i" do
    assert Y2024.D10.p1(input_string()) == 744
  end

  test "p2e" do
    assert Y2024.D10.p2(get_example_input_3()) == 81
  end

  test "p2i" do
    assert Y2024.D10.p2(input_string()) == 1651
  end
end
