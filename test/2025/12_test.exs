import AOC

aoc_test 2025, 12, async: true do
  test "p1 example" do
    input = """
    0:
    #..
    ##.
    .##

    3x2: 1
    2x2: 1
    """
    assert p1(input) == 1
  end

  test "p1 real input" do
    assert p1(input_string()) == 406
  end
end
