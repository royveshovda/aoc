import AOC

aoc 2023, 15 do
  @moduledoc """
  https://adventofcode.com/2023/day/15
  """

  @doc """
      iex> p1(example_string())
      1320

      iex> p1(input_string())
      505379
  """
  def p1(input) do
    input
    |> parse()
    |> Enum.map(fn line ->
      line
      |> run_hash()
    end)
    |> Enum.sum()
  end

  def run_hash(string) do
    vals = to_charlist(string)
    Enum.reduce(vals, 0, fn val, acc ->
      s1 = acc + val
      s2 = s1 * 17
      s3 = rem(s2, 256)
      s3
    end)
  end

  @doc """
      iex> p2(example_string())
      145

      iex> p2(input_string())
      263211
  """
  def p2(input) do
    input
    |> parse()
    |> prepare_labels()
    |> Enum.group_by(fn {_, _, _, box} -> box end)
    |> Enum.map(fn {box_id, operations} ->
      process_box(box_id, operations)
    end)
    |> Enum.map(&calculate_score/1)
    |> Enum.sum()
  end

  def calculate_score({box_id, values}) do
    box = box_id + 1
    Enum.with_index(values, 1)
    |> Enum.map(fn {{_label, focal}, index} ->
      focal * index * box
    end)
    |> Enum.sum()
  end

  def process_box(box_id, operations) do
    values =
      Enum.reduce(operations, [], fn {label, op, focal, _hash}, acc ->
        case op do
          :minus ->
            res = Enum.reject(acc, fn {l, _} -> l == label end)
            res
          :equal ->
            case Enum.any?(acc, fn {l, _} -> l == label end) do
              true ->
                Enum.map(acc, fn {l, _} = current ->
                  if l == label do
                    {l, focal}
                  else
                    current
                  end
                end)
              false ->
                List.insert_at(acc, -1, {label, focal})
            end
        end
      end)
    {box_id, values}
  end

  def prepare_labels(operations) do
    Enum.map(operations, fn operation ->
      case String.contains?(operation, "-") do
        true ->
          [label] = String.split(operation, "-", trim: true)
          {label, :minus, 0, run_hash(label)}
        false ->
          [label, value] = String.split(operation, "=")
          {label, :equal, String.to_integer(value), run_hash(label)}
      end
    end)
  end

  def parse(input) do
    input
    |> String.split(",")
  end
end
