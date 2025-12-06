import AOC

aoc 2021, 4 do
  @moduledoc """
  Day 4: Giant Squid

  Play Bingo with a giant squid.
  Part 1: Find the first board to win
  Part 2: Find the last board to win
  """

  @doc """
  Part 1: Find the first winning board and calculate score.
  Score = sum of unmarked numbers * winning number

  ## Examples

      iex> p1("7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1\\n\\n22 13 17 11  0\\n 8  2 23  4 24\\n21  9 14 16  7\\n 6 10  3 18  5\\n 1 12 20 15 19\\n\\n 3 15  0  2 22\\n 9 18 13 17  5\\n19  8  7 25 23\\n20 11 10 24  4\\n14 21 16 12  6\\n\\n14 21 17 24  4\\n10 16 15  9 19\\n18  8 23 26 20\\n22 11 13  6  5\\n 2  0 12  3  7")
      4512
  """
  def p1(input) do
    {numbers, boards} = parse(input)
    play_to_win(numbers, boards)
  end

  @doc """
  Part 2: Find the last board to win and calculate score.

  ## Examples

      iex> p2("7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1\\n\\n22 13 17 11  0\\n 8  2 23  4 24\\n21  9 14 16  7\\n 6 10  3 18  5\\n 1 12 20 15 19\\n\\n 3 15  0  2 22\\n 9 18 13 17  5\\n19  8  7 25 23\\n20 11 10 24  4\\n14 21 16 12  6\\n\\n14 21 17 24  4\\n10 16 15  9 19\\n18  8 23 26 20\\n22 11 13  6  5\\n 2  0 12  3  7")
      1924
  """
  def p2(input) do
    {numbers, boards} = parse(input)
    play_to_lose(numbers, boards)
  end

  defp play_to_win([num | rest], boards) do
    boards = mark_boards(boards, num)

    case Enum.find(boards, &winner?/1) do
      nil -> play_to_win(rest, boards)
      winner -> score(winner, num)
    end
  end

  defp play_to_lose([num | rest], boards) do
    boards = mark_boards(boards, num)

    case boards do
      [last] ->
        if winner?(last), do: score(last, num), else: play_to_lose(rest, [last])

      _ ->
        play_to_lose(rest, Enum.reject(boards, &winner?/1))
    end
  end

  defp mark_boards(boards, num) do
    Enum.map(boards, fn board ->
      Enum.map(board, fn row ->
        Enum.map(row, fn
          {^num, _} -> {num, true}
          cell -> cell
        end)
      end)
    end)
  end

  defp winner?(board) do
    rows_win?(board) or cols_win?(board)
  end

  defp rows_win?(board) do
    Enum.any?(board, fn row ->
      Enum.all?(row, fn {_, marked} -> marked end)
    end)
  end

  defp cols_win?(board) do
    board
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> rows_win?()
  end

  defp score(board, winning_num) do
    unmarked_sum =
      board
      |> List.flatten()
      |> Enum.reject(fn {_, marked} -> marked end)
      |> Enum.map(fn {num, _} -> num end)
      |> Enum.sum()

    unmarked_sum * winning_num
  end

  defp parse(input) do
    [numbers_line | board_sections] = String.split(input, "\n\n", trim: true)

    numbers =
      numbers_line
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    boards =
      Enum.map(board_sections, fn section ->
        section
        |> String.split("\n", trim: true)
        |> Enum.map(fn line ->
          line
          |> String.split(~r/\s+/, trim: true)
          |> Enum.map(&{String.to_integer(&1), false})
        end)
      end)

    {numbers, boards}
  end
end
