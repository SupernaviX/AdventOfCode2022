defmodule Day25 do
  def part1(input) do
    decimal_answer = Enum.map(input, &to_decimal/1) |> Enum.sum()
    to_snafu(decimal_answer)
  end

  defp to_decimal("" <> snafu) do
    String.codepoints(snafu)
      |> Enum.reverse()
      |> to_decimal()
  end
  defp to_decimal([]), do: 0
  defp to_decimal([digit | rest]) do
    parse_snafu_digit(digit) + (5 * to_decimal(rest))
  end

  defp parse_snafu_digit("2"), do: 2
  defp parse_snafu_digit("1"), do: 1
  defp parse_snafu_digit("0"), do: 0
  defp parse_snafu_digit("-"), do: -1
  defp parse_snafu_digit("="), do: -2

  defp to_snafu(0), do: ""
  defp to_snafu(decimal) do
    rest = div(decimal, 5)
    case rem(decimal, 5) do
      4 -> to_snafu(rest + 1) <> "-"
      3 -> to_snafu(rest + 1) <> "="
      digit -> to_snafu(rest) <> Integer.to_string(digit)
    end
  end
end

input = File.stream!("input") |> Enum.map(&String.trim/1)
IO.puts(Day25.part1(input))
