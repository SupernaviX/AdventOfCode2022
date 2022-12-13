defmodule Day9 do
  @steps %{
    "L" => {-1, 0},
    "R" => {1, 0},
    "U" => {0, -1},
    "D" => {0, 1}
  }
  def part1(input) do
    input
      |> Enum.map(&parse_row/1)
      |> Enum.reduce({ 0, 0, 0, 0, MapSet.new }, &move_rope/2)
      |> elem(4)
      |> MapSet.size()
  end

  def part2(input) do
    rope = List.duplicate({ 0, 0 }, 10)
    input
      |> Enum.map(&parse_row/1)
      |> Enum.reduce({ rope, MapSet.new}, &move_long_rope/2)
      |> elem(1)
      |> MapSet.size()
  end

  defp parse_row(row) do
    [dir, amt] = String.split(row, " ")
    { dir, String.to_integer(amt) }
  end

  defp move_rope({ _, 0 }, state), do: state
  defp move_rope({ dir, amt }, { hx, hy, tx, ty, seen }) do
    { dx, dy } = @steps[dir]
    { newhx, newhy } = { hx + dx, hy + dy }
    { newtx, newty } = move_tail({ tx, ty }, { newhx, newhy })
    newseen = MapSet.put(seen, { newtx, newty })
    move_rope({ dir, amt - 1 }, { newhx, newhy, newtx, newty, newseen })
  end

  defp move_long_rope({ _, 0 }, state), do: state
  defp move_long_rope({ dir, amt }, { [{ hx, hy } | tail], seen }) do
    { dx, dy } = @steps[dir]
    { newhx, newhy } = { hx + dx, hy + dy }
    newtail = Enum.scan(tail, { newhx, newhy }, &move_tail/2)
    newseen = MapSet.put(seen, List.last(newtail))
    move_long_rope({ dir, amt - 1 }, { [{ newhx, newhy } | newtail], newseen })
  end

  defp move_tail({ tx, ty }, { hx, hy }) do
    { dx, dy } = { tx - hx, ty - hy }
    if (abs(dx) < 2 and abs(dy) < 2) do
      { tx, ty }
    else
      { tx - sign(dx), ty - sign(dy) }
    end
  end

  defp sign(int) when int > 0, do: 1
  defp sign(int) when int < 0, do: -1
  defp sign(0), do: 0

end

input = File.stream!("input") |> Enum.map(&String.trim/1)
IO.puts(Day9.part1(input))
IO.puts(Day9.part2(input))
