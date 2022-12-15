defmodule Day13 do
  def part1(input) do
    input
      |> Enum.chunk_every(3)
      |> Enum.with_index(1)
      |> Enum.filter(fn { [line1, line2 | _], _ } -> in_right_order(line1, line2) end)
      |> Enum.map(fn { _, idx } -> idx end)
      |> Enum.sum()
  end
  def part2(input) do
    packets = (["[[2]]", "[[6]]"] ++ input)
      |> Enum.filter(&(&1 != ""))
      |> Enum.map(&parse/1)
      |> Enum.sort(&in_right_order/2)
    start_packet = Enum.find_index(packets, &(&1 == [[2]])) + 1
    end_packet = Enum.find_index(packets, &(&1 == [[6]])) + 1
    start_packet * end_packet
  end

  defp in_right_order("" <> line1, "" <> line2) do
    in_right_order(parse(line1), parse(line2))
  end
  defp in_right_order(left, right) do
    compare(left, right) == 1
  end


  defp parse(line) do
    { parsed, "" } = do_parse(line)
    parsed
  end
  defp do_parse("[]" <> rest), do: { [], rest }
  defp do_parse("[" <> rest), do: do_parse_item(rest)
  defp do_parse("," <> rest), do: do_parse_item(rest)
  defp do_parse("]" <> rest), do: { [], rest }
  defp do_parse(rest), do: Integer.parse(rest)
  defp do_parse_item(rest) do
    { item, rest } = do_parse(rest)
    { tail, rest } = do_parse(rest)
    { [item|tail], rest }
  end

  defp compare(left, right) do
    cond do
      is_number(left) and is_number(right) -> sign(right - left)
      is_number(left) -> compare([left], right)
      is_number(right) -> compare(left, [right])
      left == [] and right == [] -> 0
      left == [] -> 1
      right == [] -> -1
      true ->
        [l|lrest] = left
        [r|rrest] = right
        cmp = compare(l, r)
        if cmp != 0 do
          cmp
        else
          compare(lrest, rrest)
        end
    end
  end

  defp sign(int) when int > 0, do: 1
  defp sign(int) when int < 0, do: -1
  defp sign(0), do: 0
end

input = File.stream!("input") |> Enum.map(&String.trim/1)
IO.puts(Day13.part1(input))
IO.puts(Day13.part2(input))
