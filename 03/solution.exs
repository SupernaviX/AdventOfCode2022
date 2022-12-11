defmodule Day3 do
  def part1(input) do
    input |> Enum.map(&String.trim/1)
      |> Enum.map(&find_unique_elements/1)
      |> Enum.map(&value/1)
      |> Enum.sum()
  end

  def part2(input) do
    input |> Enum.map(&String.trim/1)
      |> Enum.chunk_every(3)
      |> Enum.map(&find_shared_elements/1)
      |> Enum.map(&value/1)
      |> Enum.sum()
  end

  defp find_unique_elements(line) do
    len = div(String.length(line), 2)
    [comp1, comp2] = String.split_at(line, len)
      |> Tuple.to_list()
      |> Enum.map(&unique_items/1)
    only_item(MapSet.intersection(comp1, comp2))
  end

  defp find_shared_elements([bag1, bag2, bag3]) do
    unique_items(bag1)
      |> MapSet.intersection(unique_items(bag2))
      |> MapSet.intersection(unique_items(bag3))
      |> only_item()
  end

  defp unique_items(items) do
    MapSet.new(String.codepoints(items))
  end

  defp only_item(set) do
    List.first(MapSet.to_list(set))
  end

  defp value(item) do
    <<codepoint::utf8>> = item
    cond do
      Enum.member?(?a..?z, codepoint) ->
        codepoint - ?a + 1
      Enum.member?(?A..?Z, codepoint) ->
        codepoint - ?A + 27
    end
  end
end

input = File.stream!("input")
IO.puts(Day3.part1(input))
IO.puts(Day3.part2(input))
