defmodule Day21 do
  def part1(input) do
    monkeys = parse(input)
    solve(monkeys)
  end
  def part2(input) do
    monkeys = parse(input)
      |> Map.update!("root", fn { left, _, right } -> { left, "=", right } end)
      |> Map.replace!("humn", :humn)
    { left, "=", right } = solve(monkeys)
    find_solution(left, right)
  end

  def parse(lines), do: Map.new(lines, &parse_monkey/1)
  defp parse_monkey(monkey) do
    [name, equation] = String.split(monkey, ": ")
    case equation do
      <<left::binary-size(4), " ", operator::binary-size(1), " ", right::binary-size(4) >> ->
        { name, { left, operator, right } }
      number ->
        { name, String.to_integer(number) }
    end
  end

  defp solve(monkeys), do: solve(monkeys, monkeys["root"])
  defp solve(monkeys, { left, op, right }) do
    left = solve(monkeys, monkeys[left])
    right = solve(monkeys, monkeys[right])
    if is_integer(left) and is_integer(right) do
      eval(left, op, right)
    else
      { left, op, right }
    end
  end
  defp solve(_, x), do: x

  defp eval(left, "+", right), do: left + right
  defp eval(left, "-", right), do: left - right
  defp eval(left, "*", right), do: left * right
  defp eval(left, "/", right), do: div(left, right)

  defp find_solution(left, right) when is_integer(left), do: find_solution(right, left)
  defp find_solution(:humn, right), do: right
  defp find_solution({ l1, "+", l2 }, right) when is_integer(l2) do
    find_solution(l1, right - l2)
  end
  defp find_solution({ l1, "+", l2 }, right) do
    find_solution(l2, right - l1)
  end
  defp find_solution({ l1, "-", l2 }, right) when is_integer(l2) do
    find_solution(l1, right + l2)
  end
  defp find_solution({ l1, "-", l2 }, right) do
    find_solution(l2, l1 - right)
  end
  defp find_solution({ l1, "*", l2 }, right) when is_integer(l2) do
    find_solution(l1, div(right, l2))
  end
  defp find_solution({ l1, "*", l2 }, right) do
    find_solution(l2, div(right, l1))
  end
  defp find_solution({ l1, "/", l2 }, right) when is_integer(l2) do
    find_solution(l1, right * l2)
  end
  defp find_solution({ l1, "/", l2 }, right) do
    find_solution(l2, div(l1, right))
  end
end

input = File.stream!("input") |> Enum.map(&String.trim/1)
IO.puts(Day21.part1(input))
IO.puts(Day21.part2(input))
