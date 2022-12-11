defmodule Day1 do
  def part1(input) do
    totals = compute_cal_totals(input)
    Enum.reduce(totals, &max/2)
  end

  def part2(input) do
    totals = compute_cal_totals(input)
    Enum.reduce(totals, [], &reduce_to_top_3/2) |> Enum.sum()
  end

  defp compute_cal_totals(input) do
    input
      |> Stream.map(&String.trim/1)
      |> Stream.chunk_while(0, &group_cals/2, fn x -> { :cont, x, 0 } end)
  end

  defp group_cals("", currsum) do
    { :cont, currsum, 0 }
  end
  defp group_cals(number, currsum) do
    { :cont, String.to_integer(number) + currsum }
  end

  defp reduce_to_top_3(next, rest) when length(rest) == 3 do
    Enum.sort([next | rest]) |> Enum.drop(1)
  end
  defp reduce_to_top_3(next, rest) do
    [next | rest]
  end
end


input = File.stream!("input")
IO.puts(Day1.part1(input))
IO.puts(Day1.part2(input))
