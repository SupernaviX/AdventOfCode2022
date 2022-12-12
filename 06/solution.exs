defmodule Day6 do
  def part1(input) do
    find_part(4, input)
  end
  def part2(input) do
    find_part(14, input)
  end

  defp find_part(count, string) do
    _find_part(count, count, String.codepoints(string))
  end
  defp _find_part(count, index, list) do
    first = Enum.take(list, count)
    if MapSet.size(MapSet.new(first)) == count do
      index
    else
      _find_part(count, index + 1, Enum.drop(list, 1))
    end
  end
end

input = File.read!("input")
IO.puts(Day6.part1(input))
IO.puts(Day6.part2(input))
