import AOC

aoc_test 2023, 3, async: true do
  test "to expand left part of a number" do
    grid = example_string() |> Y2023.D3.parse()
    {number_pos, number} = Y2023.D3.expand_number_in_pos(grid, {0, 0})
    assert {0, 0} in number_pos
    assert {0, 1} in number_pos
    assert {0, 2} in number_pos
    assert number == 467
  end

  test "to expand mid part of a number" do
    grid = example_string() |> Y2023.D3.parse()
    {number_pos, number} = Y2023.D3.expand_number_in_pos(grid, {0, 1})
    assert {0, 0} in number_pos
    assert {0, 1} in number_pos
    assert {0, 2} in number_pos
    assert number == 467
  end

  test "to expand right part of a number" do
    grid = example_string() |> Y2023.D3.parse()
    {number_pos, number} = Y2023.D3.expand_number_in_pos(grid, {0, 2})
    assert {0, 0} in number_pos
    assert {0, 1} in number_pos
    assert {0, 2} in number_pos
    assert number == 467
  end
end
