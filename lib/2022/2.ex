import AOC

aoc 2022, 2 do
  @moduledoc """
  Day 2: Rock Paper Scissors

  Score rock-paper-scissors games. A/X=Rock, B/Y=Paper, C/Z=Scissors.
  Shape score: Rock=1, Paper=2, Scissors=3.
  Outcome: Loss=0, Draw=3, Win=6.
  Part 2: X=need to lose, Y=draw, Z=win.
  """

  @doc """
  Part 1: Calculate total score with X/Y/Z as shapes.

  ## Examples

      iex> p1("A Y\\nB X\\nC Z")
      15
  """
  def p1(input) do
    input
    |> parse()
    |> Enum.map(&score_round_p1/1)
    |> Enum.sum()
  end

  @doc """
  Part 2: Calculate total score with X/Y/Z as outcomes.

  ## Examples

      iex> p2("A Y\\nB X\\nC Z")
      12
  """
  def p2(input) do
    input
    |> parse()
    |> Enum.map(&score_round_p2/1)
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [them, us] = String.split(line, " ")
      {them, us}
    end)
  end

  # Part 1: X/Y/Z are shapes (Rock/Paper/Scissors)
  # A/X = Rock (1), B/Y = Paper (2), C/Z = Scissors (3)
  # Loss = 0, Draw = 3, Win = 6
  defp score_round_p1({them, us}) do
    shape_score = case us do
      "X" -> 1  # Rock
      "Y" -> 2  # Paper
      "Z" -> 3  # Scissors
    end

    outcome_score = case {them, us} do
      {"A", "X"} -> 3  # Rock vs Rock = Draw
      {"A", "Y"} -> 6  # Rock vs Paper = Win
      {"A", "Z"} -> 0  # Rock vs Scissors = Loss
      {"B", "X"} -> 0  # Paper vs Rock = Loss
      {"B", "Y"} -> 3  # Paper vs Paper = Draw
      {"B", "Z"} -> 6  # Paper vs Scissors = Win
      {"C", "X"} -> 6  # Scissors vs Rock = Win
      {"C", "Y"} -> 0  # Scissors vs Paper = Loss
      {"C", "Z"} -> 3  # Scissors vs Scissors = Draw
    end

    shape_score + outcome_score
  end

  # Part 2: X/Y/Z are outcomes (Loss/Draw/Win)
  # X = need to lose, Y = draw, Z = win
  defp score_round_p2({them, outcome}) do
    # Determine what shape we need to play
    us = case {them, outcome} do
      # They play Rock
      {"A", "X"} -> "Z"  # Need to lose -> Scissors
      {"A", "Y"} -> "X"  # Need to draw -> Rock
      {"A", "Z"} -> "Y"  # Need to win -> Paper
      # They play Paper
      {"B", "X"} -> "X"  # Need to lose -> Rock
      {"B", "Y"} -> "Y"  # Need to draw -> Paper
      {"B", "Z"} -> "Z"  # Need to win -> Scissors
      # They play Scissors
      {"C", "X"} -> "Y"  # Need to lose -> Paper
      {"C", "Y"} -> "Z"  # Need to draw -> Scissors
      {"C", "Z"} -> "X"  # Need to win -> Rock
    end

    shape_score = case us do
      "X" -> 1  # Rock
      "Y" -> 2  # Paper
      "Z" -> 3  # Scissors
    end

    outcome_score = case outcome do
      "X" -> 0  # Loss
      "Y" -> 3  # Draw
      "Z" -> 6  # Win
    end

    shape_score + outcome_score
  end
end
