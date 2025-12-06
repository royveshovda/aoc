import AOC

aoc_test 2021, 14, async: true do
  @example "NNCB\n\nCH -> B\nHH -> N\nCB -> H\nNH -> C\nHB -> C\nHC -> B\nHN -> C\nNN -> C\nBH -> H\nNC -> B\nNB -> B\nBN -> B\nBB -> N\nBC -> B\nCC -> N\nCN -> C"

  test "part 1 example" do
    assert Y2021.D14.p1(@example) == 1588
  end

  test "part 1 input" do
    assert Y2021.D14.p1(input_string()) == 3259
  end

  test "part 2 example" do
    assert Y2021.D14.p2(@example) == 2_188_189_693_529
  end

  test "part 2 input" do
    assert Y2021.D14.p2(input_string()) == 3_459_174_981_021
  end
end
