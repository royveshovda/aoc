import AOC

aoc_test 2025, 8, async: true do
  test "part 1 with input" do
      assert Y2025.D8.p1(input_string()) == 98_696
    end

    test "part 2 with input" do
      assert Y2025.D8.p2(input_string()) == 2_245_203_960
    end
end
