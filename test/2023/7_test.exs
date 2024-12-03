import AOC

aoc_test 2023, 7, async: true do
  test "five_of_a_kind" do
    assert Y2023.D7.get_hand_type(%{c1: 2, c2: 2, c3: 2, c4: 2, c5: 2}) == :five_of_a_kind
  end

  test "four_of_a_kind" do
    assert Y2023.D7.get_hand_type(%{c1: 2, c2: 2, c3: 2, c4: 2, c5: 3}) == :four_of_a_kind
  end

  test "full_house" do
    assert Y2023.D7.get_hand_type(%{c1: 2, c2: 2, c3: 2, c4: 3, c5: 3}) == :full_house
  end

  test "three_of_a_kind" do
    assert Y2023.D7.get_hand_type(%{c1: 2, c2: 2, c3: 2, c4: 3, c5: 4}) == :three_of_a_kind
  end

  test "two_pairs" do
    assert Y2023.D7.get_hand_type(%{c1: 2, c2: 2, c3: 3, c4: 3, c5: 4}) == :two_pairs
  end

  test "one_pair" do
    assert Y2023.D7.get_hand_type(%{c1: 2, c2: 2, c3: 3, c4: 4, c5: 5}) == :one_pair
  end

  test "high_card" do
    assert Y2023.D7.get_hand_type(%{c1: 2, c2: 3, c3: 4, c4: 5, c5: 6}) == :high_card
  end

  test "compare hand types" do
    assert Y2023.D7.compare_types(:five_of_a_kind, :four_of_a_kind) == :left_hand_wins
    assert Y2023.D7.compare_types(:four_of_a_kind, :five_of_a_kind) == :right_hand_wins
    assert Y2023.D7.compare_types(:five_of_a_kind, :five_of_a_kind) == :tie
  end

  test "compare cards" do
    #assert Y2023.D7.compare_cards([1,2,3,4,5], [1,2,3,4,5]) == :tie
    assert Y2023.D7.compare_cards(%{c1: 1, c2: 2, c3: 3, c4: 4, c5: 5}, %{c1: 11, c2: 22, c3: 33, c4: 44, c5: 55}) == :right_hand_wins
    assert Y2023.D7.compare_cards(%{c1: 1, c2: 2, c3: 3, c4: 4, c5: 5}, %{c1: 1, c2: 2, c3: 3, c4: 4, c5: 5}) == :tie
    assert Y2023.D7.compare_cards(%{c1: 1, c2: 2, c3: 3, c4: 4, c5: 6}, %{c1: 1, c2: 2, c3: 3, c4: 4, c5: 5}) == :left_hand_wins
    assert Y2023.D7.compare_cards(%{c1: 1, c2: 2, c3: 3, c4: 4, c5: 5}, %{c1: 1, c2: 2, c3: 3, c4: 4, c5: 6}) == :right_hand_wins
  end

  test "left hand less than or equal" do
    assert Y2023.D7.left_hand_less_than_or_equal(
      %{hand_type: :five_of_a_kind, cards: %{c1: 1, c2: 2, c3: 3, c4: 4, c5: 5}},
      %{hand_type: :five_of_a_kind, cards: %{c1: 1, c2: 2, c3: 3, c4: 4, c5: 5}})
      == true

      assert Y2023.D7.left_hand_less_than_or_equal(
        %{hand_type: :five_of_a_kind, cards: %{c1: 1, c2: 2, c3: 3, c4: 4, c5: 5}},
        %{hand_type: :four_of_a_kind, cards: %{c1: 1, c2: 2, c3: 3, c4: 4, c5: 5}})
        == false
  end
end
