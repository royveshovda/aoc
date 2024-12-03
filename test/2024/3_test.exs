import AOC

aoc_test 2024, 3, async: true do
  test "p1e" do
    assert Y2024.D3.p1(example_string()) == 161
  end

  test "p1i" do
    assert Y2024.D3.p1(input_string()) == 161085926
  end

  test "p2e" do
    s2 = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"
    assert Y2024.D3.p2(s2) == 48
  end

  test "p2i" do
    assert Y2024.D3.p2(input_string()) == 82_045_421
  end
end
