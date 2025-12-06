import AOC

aoc_test 2021, 10, async: true do
  @example """
  [({(<(())[]>[[{[]{<()<>>
  [(()[<>])]({[<{<<[]>>(
  {([(<{}[<>[]}>{[]{[(<()>
  (((({<>}<{<{<>}{[]{[]{}
  [[<[([]))<([[{}[[()]]]
  [{[{({}]{}}([{[{{{}}([]
  {<[[]]>}<{[{[{[]{()[[[]
  [<(<(<(<{}))><([]([]()
  <{([([[(<>()){}]>(<<{{
  <{([{{}}[<[[[<>{}]]]>[]]
  """

  test "part 1 example" do
    assert Y2021.D10.p1(String.trim(@example)) == 26397
  end

  test "part 1 input" do
    assert Y2021.D10.p1(input_string()) == 299_793
  end

  test "part 2 example" do
    assert Y2021.D10.p2(String.trim(@example)) == 288_957
  end

  test "part 2 input" do
    assert Y2021.D10.p2(input_string()) == 3_654_963_618
  end
end
