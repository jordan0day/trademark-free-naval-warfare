defmodule AssKickers do
  @behaviour AdmiralBehavior

  def team_name() do
    "Ass Kickers"
  end

  def initialize() do
    GameBoard.get_blank_board()
    |> GameBoard.place_ship(:cruiser, "D3", :vertical)
    |> GameBoard.place_ship(:aircraft_carrier, "E3", :horizontal)
    |> GameBoard.place_ship(:destroyer, "A4", :vertical)
    |> GameBoard.place_ship(:battleship, "H5", :vertical)
    |> GameBoard.place_ship(:submarine, "C6", :vertical)
  end

  def fire(enemy_board, previous_shots, shot_results, _state) do
    get_random_coordinate()
  end

  defp get_random_coordinate() do
    columns = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
    rows = 1..10

    col = Enum.random(columns)
    row = Enum.random(rows)

    "#{col}#{row}"
  end

  defp pick_random_direction() do
    case :rand.uniform(2) do
      1 -> :horizontal
      2 -> :vertical
    end
  end
end
