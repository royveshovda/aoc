import AOC

aoc_test 2024, 24, async: true do
  test "p1e" do
    assert Y2024.D24.p1(example_string()) == 9
  end

  test "p1i" do
    assert Y2024.D24.p1(input_string()) == 56_278_503_604_006
  end

  # test "p2e" do
  #   assert Y2024.D24.p2(example_string()) == "z00,z01,z02,z05"
  # end

  test "p2i" do
    assert Y2024.D24.p2(input_string()) == "bhd,brk,dhg,dpd,nbf,z06,z23,z38"
  end
end
