defmodule TFNW do
  @moduledoc """
  Documentation for TFNW.
  """

  @type player :: module

  @type player_record :: %{
    player: player,
    rounds_played: non_neg_integer,
    wins: non_neg_integer
  }

  @type round :: %{
    players: [player],
    winner: player | nil
  }

  def start do
    # Look up the list of contenders in priv/admirals
    admirals =
      Path.wildcard("priv/admirals/*.exs")
      |> Enum.map(&(Code.load_file(&1)))
      |> Enum.map(fn [{module, _}] -> module end)

    IO.puts "Admirals: #{inspect admirals}"

    rounds =
      admirals
      |> combinations(2)
      |> Enum.map(&Enum.shuffle/1) # Randomize order of "team1" & "team2"
      |> Enum.shuffle() # Randomize matchup list

    IO.puts "Matchups:"
    Enum.each(rounds, fn [team1, team2] ->
      IO.puts "#{inspect team1} vs. #{inspect team2}"
    end)
    IO.puts "\n"

    admiral_wins = Map.new(admirals, fn admiral -> {admiral, 0} end)

    final_results = Enum.reduce(rounds, admiral_wins, fn round, results ->
      winner = Game.play_game(round)

      Map.put(results, winner, results[winner] + 1)
    end)

    IO.puts "Final results: #{inspect final_results, pretty: true}"

    winner =
      final_results
      |> Enum.sort_by(fn {module, wins} -> wins end)
      |> List.last

    IO.puts "****************************************"
    IO.puts "             OVERALL WINNER             "
    IO.puts "****************************************"
    IO.puts "* #{inspect winner}"
    IO.puts "****************************************"
  end

  def start_one(player1_filename, player2_filename) do
    [{player1, _}] = Code.load_file(player1_filename, "priv/admirals")
    IO.puts "Player1: #{inspect player1}"
    [{player2, _}] = Code.load_file(player2_filename, "priv/admirals")
    IO.puts "Player2: #{inspect player2}"

    Game.play_game([player1, player2])
  end

  # Thanks Alan!
  # See https://github.com/alanvoss/connect_four/blob/rentpath_techtalk/lib/connect_four/controller.ex#L145
  defp combinations(_, 0), do: [[]]
  defp combinations([], _), do: []
  defp combinations(_deck = [x|xs], n) when is_integer(n) do
    (for y <- combinations(xs, n - 1), do: [x|y]) ++ combinations(xs, n)
  end
end
