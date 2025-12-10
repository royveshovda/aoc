import AOC
import Bitwise

aoc 2025, 10 do
  @moduledoc """
  https://adventofcode.com/2025/day/10
  """

  @doc """
      iex> p1(example_string(0))
      7
  """
  def p1(input) do
    input
    |> parse()
    |> Enum.map(&min_presses/1)
    |> Enum.sum()
  end

  @doc """
      iex> p2(example_string(0))
      33
  """
  def p2(input) do
    input
    |> parse()
    |> Enum.map(&min_presses_counts/1)
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    pattern = Regex.run(~r/\[([.#]+)\]/, line, capture: :all_but_first) |> List.first()

    buttons =
      Regex.scan(~r/\(([^)]*)\)/, line, capture: :all_but_first)
      |> Enum.map(fn [list] ->
        list
        |> String.split(",", trim: true)
        |> Enum.reject(&(&1 == ""))
        |> Enum.map(&String.to_integer/1)
      end)

    targets =
      Regex.run(~r/\{([^}]*)\}/, line, capture: :all_but_first)
      |> List.first()
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)

    target_mask =
      pattern
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(0, fn
        {"#", idx}, acc -> acc ||| (1 <<< idx)
        {".", _idx}, acc -> acc
      end)

    button_masks =
      buttons
      |> Enum.map(fn indices ->
        Enum.reduce(indices, 0, fn idx, acc -> acc ||| (1 <<< idx) end)
      end)

    %{
      len: String.length(pattern),
      target_mask: target_mask,
      button_masks: button_masks,
      buttons: buttons,
      targets: targets
    }
  end

  defp min_presses(%{len: len, target_mask: target_mask, button_masks: buttons}) do
    k = length(buttons)

    rows =
      Enum.map(0..(len - 1), fn light_idx ->
        mask =
          buttons
          |> Enum.with_index()
          |> Enum.reduce(0, fn {button_mask, btn_idx}, acc ->
            if Bitwise.band(button_mask, 1 <<< light_idx) != 0 do
              acc ||| (1 <<< btn_idx)
            else
              acc
            end
          end)

        rhs = if Bitwise.band(target_mask, 1 <<< light_idx) == 0, do: 0, else: 1
        {mask, rhs}
      end)

    {rows_rref, pivots} = rref(rows, k)

    if Enum.any?(rows_rref, fn {mask, rhs} -> mask == 0 and rhs == 1 end) do
      raise "No solution for machine"
    end

    free_cols = free_columns(k, pivots)

    particular =
      Enum.reduce(pivots, 0, fn {col, row_idx}, acc ->
        {_, rhs} = Enum.at(rows_rref, row_idx)
        if rhs == 1, do: acc ||| (1 <<< col), else: acc
      end)

    basis =
      Enum.map(free_cols, fn free_col ->
        Enum.reduce(pivots, 1 <<< free_col, fn {pivot_col, row_idx}, vec ->
          {row_mask, _rhs} = Enum.at(rows_rref, row_idx)

          if Bitwise.band(row_mask, 1 <<< free_col) != 0 do
            vec ||| (1 <<< pivot_col)
          else
            vec
          end
        end)
      end)

    search_minimum(particular, basis)
  end

  defp min_presses_counts(%{buttons: buttons, targets: targets}) do
    button_max = button_max_press(buttons, targets)
    {rows, pivots} = rref_counts(buttons, targets)
    free_cols = free_columns(length(buttons), pivots)

    pivot_rows =
      Enum.map(pivots, fn {col, row_idx} ->
        {coeffs, rhs} = Enum.at(rows, row_idx)

        free_coeffs =
          free_cols
          |> Enum.map(fn c -> {c, Enum.at(coeffs, c)} end)
          |> Enum.reject(fn {_c, v} -> rat_zero?(v) end)

        {col, rhs, free_coeffs}
      end)

    best =
      search_free_vars(
        free_cols,
        pivot_rows,
        button_max,
        %{},
        0,
        :infinity
      )

    if best == :infinity do
      raise "No solution for machine"
    else
      best
    end
  end

  defp rref(rows, cols) do
    do_rref(rows, cols, 0, [], 0)
  end

  defp do_rref(rows, cols, _row_idx, pivots, col_idx) when col_idx == cols do
    {rows, Enum.reverse(pivots)}
  end

  defp do_rref(rows, cols, row_idx, pivots, col_idx) do
    pivot_row =
      Enum.find_index(rows |> Enum.drop(row_idx), fn {mask, _rhs} ->
        Bitwise.band(mask, 1 <<< col_idx) != 0
      end)
      |> case do
        nil -> nil
        idx -> idx + row_idx
      end

    if pivot_row == nil do
      do_rref(rows, cols, row_idx, pivots, col_idx + 1)
    else
      rows = swap_rows(rows, row_idx, pivot_row)
      {pivot_mask, pivot_rhs} = Enum.at(rows, row_idx)

      rows =
        rows
        |> Enum.with_index()
        |> Enum.map(fn {row, idx} ->
          if idx != row_idx and Bitwise.band(elem(row, 0), 1 <<< col_idx) != 0 do
            {Bitwise.bxor(elem(row, 0), pivot_mask), Bitwise.bxor(elem(row, 1), pivot_rhs)}
          else
            row
          end
        end)

      do_rref(rows, cols, row_idx + 1, [{col_idx, row_idx} | pivots], col_idx + 1)
    end
  end

  defp rref_counts(buttons, targets) do
    cols = length(buttons)

    rows =
      targets
      |> Enum.with_index()
      |> Enum.map(fn {t, idx} ->
        coeffs =
          buttons
          |> Enum.map(fn btn -> if idx in btn, do: rat(1), else: rat(0) end)

        {coeffs, rat(t)}
      end)

    rref_rat(rows, cols)
  end

  defp rref_rat(rows, cols) do
    do_rref_rat(rows, cols, 0, [], 0)
  end

  defp do_rref_rat(rows, cols, _row_idx, pivots, col_idx) when col_idx == cols do
    {rows, Enum.reverse(pivots)}
  end

  defp do_rref_rat(rows, cols, row_idx, pivots, col_idx) do
    pivot_row =
      Enum.find_index(Enum.drop(rows, row_idx), fn {coeffs, _rhs} ->
        coeff = Enum.at(coeffs, col_idx)
        rat_zero?(coeff) == false
      end)
      |> case do
        nil -> nil
        idx -> idx + row_idx
      end

    if pivot_row == nil do
      do_rref_rat(rows, cols, row_idx, pivots, col_idx + 1)
    else
      rows = swap_rows(rows, row_idx, pivot_row)
      {pivot_coeffs, pivot_rhs} = Enum.at(rows, row_idx)
      pivot_val = Enum.at(pivot_coeffs, col_idx)

      {pivot_coeffs, pivot_rhs} =
        {scale_row(pivot_coeffs, rat_div(rat(1), pivot_val)), rat_div(pivot_rhs, pivot_val)}

      rows = List.replace_at(rows, row_idx, {pivot_coeffs, pivot_rhs})

      rows =
        rows
        |> Enum.with_index()
        |> Enum.map(fn {row, idx} ->
          if idx == row_idx do
            row
          else
            {coeffs, rhs} = row
            factor = Enum.at(coeffs, col_idx)

            if rat_zero?(factor) do
              row
            else
              new_coeffs =
                coeffs
                |> Enum.zip(pivot_coeffs)
                |> Enum.map(fn {a, b} -> rat_sub(a, rat_mul(factor, b)) end)

              new_rhs = rat_sub(rhs, rat_mul(factor, pivot_rhs))
              {new_coeffs, new_rhs}
            end
          end
        end)

      do_rref_rat(rows, cols, row_idx + 1, [{col_idx, row_idx} | pivots], col_idx + 1)
    end
  end

  defp swap_rows(rows, i, j) when i == j, do: rows

  defp swap_rows(rows, i, j) do
    row_i = Enum.at(rows, i)
    row_j = Enum.at(rows, j)

    rows
    |> List.replace_at(i, row_j)
    |> List.replace_at(j, row_i)
  end

  defp free_columns(cols, pivots) do
    pivot_set = MapSet.new(Enum.map(pivots, &elem(&1, 0)))

    for c <- 0..(cols - 1), MapSet.member?(pivot_set, c) == false, do: c
  end

  defp button_max_press(buttons, targets) do
    Enum.map(buttons, fn btn ->
      btn
      |> Enum.map(&Enum.at(targets, &1))
      |> Enum.min(fn -> 0 end)
    end)
  end

  defp search_free_vars([], pivot_rows, button_max, assignment, current_sum, best) do
    case evaluate_solution(pivot_rows, button_max, assignment, current_sum) do
      {:ok, total} -> min(total, best)
      :error -> best
    end
  end

  defp search_free_vars([col | rest], pivot_rows, button_max, assignment, current_sum, best) do
    max_press = Enum.at(button_max, col)

    Enum.reduce_while(0..max_press, best, fn value, acc_best ->
      new_sum = current_sum + value

      if new_sum >= acc_best do
        {:halt, acc_best}
      else
        new_assignment = Map.put(assignment, col, value)
        next_best = search_free_vars(rest, pivot_rows, button_max, new_assignment, new_sum, acc_best)
        {:cont, min(acc_best, next_best)}
      end
    end)
  end

  defp evaluate_solution(pivot_rows, button_max, assignment, base_sum) do
    Enum.reduce_while(pivot_rows, {:ok, base_sum}, fn {pivot_col, rhs, free_coeffs}, {:ok, acc} ->
      value =
        Enum.reduce(free_coeffs, rhs, fn {col, coeff}, acc_rhs ->
          free_val = Map.get(assignment, col, 0)
          rat_sub(acc_rhs, rat_mul(coeff, rat(free_val)))
        end)

      case rat_to_int(value) do
        nil -> {:halt, :error}
        int when int < 0 -> {:halt, :error}
        int ->
          if int > Enum.at(button_max, pivot_col) do
            {:halt, :error}
          else
            {:cont, {:ok, acc + int}}
          end
      end
    end)
  end

  defp search_minimum(particular, basis) do
    basis_count = length(basis)

    case basis_count do
      0 -> popcount(particular)
      _ ->
        max_mask = (1 <<< basis_count) - 1

        Enum.reduce(0..max_mask, :infinity, fn combo, best ->
          candidate =
            Enum.reduce(0..(basis_count - 1), particular, fn idx, acc ->
              if Bitwise.band(combo, 1 <<< idx) != 0 do
                Bitwise.bxor(acc, Enum.at(basis, idx))
              else
                acc
              end
            end)

          weight = popcount(candidate)

          if weight < best, do: weight, else: best
        end)
    end
  end

  defp popcount(n) do
    n
    |> Integer.digits(2)
    |> Enum.count(&(&1 == 1))
  end

  defp rat(n) when is_integer(n), do: {n, 1}

  defp rat(num, den) do
    g = Integer.gcd(num, den)
    den = div(den, g)
    num = div(num, g)

    if den < 0 do
      {-num, -den}
    else
      {num, den}
    end
  end

  defp rat_sub({a1, b1}, {a2, b2}), do: rat(a1 * b2 - a2 * b1, b1 * b2)
  defp rat_mul({a1, b1}, {a2, b2}), do: rat(a1 * a2, b1 * b2)
  defp rat_div({a1, b1}, {a2, b2}), do: rat(a1 * b2, b1 * a2)
  defp rat_zero?({n, _d}), do: n == 0
  defp rat_to_int({n, d}) when rem(n, d) == 0, do: div(n, d)
  defp rat_to_int(_), do: nil

  defp scale_row(coeffs, factor) do
    Enum.map(coeffs, fn c -> rat_mul(c, factor) end)
  end
end
