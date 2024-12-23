import AOC

aoc_test 2024, 23, async: true do
  test "p1e" do
    assert Y2024.D23.p1(example_string()) == 7
  end

  test "p1i" do
    assert Y2024.D23.p1(input_string()) == 1366
  end

  test "p2e" do
    assert Y2024.D23.p2(example_string()) == "co,de,ka,ta"
  end

  test "p2i" do
    assert Y2024.D23.p2(input_string()) == "bs,cf,cn,gb,gk,jf,mp,qk,qo,st,ti,uc,xw"
  end
end
