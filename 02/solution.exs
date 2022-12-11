defmodule Day2 do
  @moves %{
    "A" => :rock,
    "B" => :paper,
    "C" => :scissors,
    "X" => :rock,
    "Y" => :paper,
    "Z" => :scissors
  }
  @scores %{ :rock => 1, :paper => 2, :scissors => 3 }
  @matchups %{
    :rock => %{ :scissors => 0, :rock => 3, :paper => 6 },
    :paper => %{ :rock => 0, :paper => 3, :scissors => 6 },
    :scissors => %{ :paper => 0, :scissors => 3, :rock => 6 },
  }
  @outcomes %{
    :rock => %{ "X" => :scissors, "Y" => :rock, "Z" => :paper },
    :paper => %{ "X" => :rock, "Y" => :paper, "Z" => :scissors },
    :scissors => %{ "X" => :paper, "Y" => :scissors, "Z" => :rock },
  }
  def part1(input) do
    input |> Enum.map(&part1score/1) |> Enum.sum()
  end

  def part2(input) do
    input |> Enum.map(&part2score/1) |> Enum.sum()
  end

  defp part1score(line) do
    yourmove = @moves[String.at(line, 0)]
    mymove = @moves[String.at(line, 2)]
    score(yourmove, mymove)
  end

  defp part2score(line) do
    yourmove = @moves[String.at(line, 0)]
    myoutcome = String.at(line, 2)
    mymove = @outcomes[yourmove][myoutcome]
    score(yourmove, mymove)
  end

  defp score(yourmove, mymove) do
    @scores[mymove] + @matchups[yourmove][mymove]
  end
end

input = File.stream!("input")
IO.puts(Day2.part1(input))
IO.puts(Day2.part2(input))
