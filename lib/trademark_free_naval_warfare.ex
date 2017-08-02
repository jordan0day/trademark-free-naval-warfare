defmodule TFNW do
  @moduledoc """
  Documentation for TFNW.
  """

  def start do
    # TODO...
    # Look up the list of contenders in priv/admirals
  end

  def start_one(player1_filename, player2_filename) do
    [{player1, _}] = Code.load_file(player1_filename, "priv/admirals")
    IO.puts "Player1: #{inspect player1}"
    [{player2, _}] = Code.load_file(player2_filename, "priv/admirals")
    IO.puts "Player2: #{inspect player2}"

    Game.play_game([player1, player2])
  end
end
