defmodule RandomAdmiral do
  @behaviour AdmiralBehavior

  def team_name() do
    now = Time.utc_now
    {us, _} = now.microsecond

    "random-#{us}"
  end

  def initialize() do
    ships = Enum.shuffle([:aircraft_carrier, :battleship, :cruiser, :submarine, :destroyer])
    blank_board = GameBoard.get_blank_board()
    # Just keep trying to randomly place ships until we've managed to place them
    # all.
    initialize(blank_board, ships)
  end

  def fire(_enemy_board, _previous_shots, _shot_results, _state) do
    get_random_coordinate()
  end

  defp initialize(board, [ship | rest_ships] = ships) do
    coordinate = get_random_coordinate()
    direction = pick_random_direction()

    case GameBoard.place_ship(board, ship, coordinate, direction) do
      {:error, _reason} ->
        # Fail. Try again.
        initialize(board, ships)
      new_board ->
        # Successfully placed the ship
        case rest_ships do
          [] ->
            # We're done!
            new_board
          _ ->
            # More ships to place
            initialize(new_board, rest_ships)
        end
    end
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
