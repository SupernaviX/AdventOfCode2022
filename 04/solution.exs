defmodule Day4 do
  def part1(input) do
    input
      |> Enum.map(&parse_line/1)
      |> Enum.filter(&fully_contained/1)
      |> length()
  end

  def part2(input) do
    input
      |> Enum.map(&parse_line/1)
      |> Enum.filter(&overlap/1)
      |> length()
  end

  defp fully_contained({ range1, range2 }) do
    range1.first <= range2.first and range1.last >= range2.last
  end

  defp overlap({ range1, range2 }) do
    not Range.disjoint?(range1, range2)
  end

  defp parse_line(line) do
    [range1, range2] = String.split(line, ",", parts: 2)
      |> Enum.map(&parse_range/1)
      |> Enum.sort_by(&{&1.first, -&1.last})
    { range1, range2 }
  end

  defp parse_range(range) do
    [first, last] = String.split(range, "-", parts: 2)
      |> Enum.map(&String.to_integer/1)
    Range.new(first, last)
  end
end

input = File.stream!("input") |> Stream.map(&String.trim/1)
IO.puts(Day4.part1(input))
IO.puts(Day4.part2(input))
