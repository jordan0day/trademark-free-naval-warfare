defmodule BrianAndCraig do
  @behaviour AdmiralBehavior

  def team_name() do
    "Brian and Craig"
  end

  def initialize() do
    ships = Enum.shuffle([:aircraft_carrier, :battleship, :cruiser, :submarine, :destroyer])
    blank_board = GameBoard.get_blank_board()
    {initialize(blank_board, ships), %{go_back_to: nil}}
  end

  def fire(_, _, [], state) do
    {"A1", state}
  end

  def fire(_enemy_board, _previous_shots, shot_results, state) do
    [last_shot | _] = shot_results
    {last_coordinate, last_result} = last_shot

    if (last_result == :hit) do
      new_state = if (is_nil(state[:go_back_to])) do
                    %{state | go_back_to: last_coordinate}
                  else
                    state
                  end
      {next_coordinate(last_coordinate, shot_results), new_state}
    else
      if (is_nil(state[:go_back_to])) do
        {next_coordinate(last_coordinate, shot_results), state}
      else
        {next_coordinate(state[:go_back_to], shot_results), %{state | go_back_to: nil}}
      end
    end
  end

  defp next_coordinate(coordinate, shot_results) do
    [last_shot | _] = shot_results
    {_, last_result} = last_shot

    provisional = if (last_result == :hit) do
                    next_coordinate_over(coordinate)
                  else
                    next_coordinate_down(coordinate)
                  end
    found = Enum.find(shot_results, fn n -> {c, _} = n; c == provisional end)
    if is_nil(found) do
      provisional
    else
      next_coordinate(provisional, shot_results)
    end
  end

  def next_coordinate_over(last_coordinate) do
    {:ok, {col, row}} = GameBoard.parse_coordinate(last_coordinate)
    new_col = <<hd(String.to_charlist(col)) + 1>>
    if (new_col == "K") do
      col <> "#{row + 1}"
    else
      new_col <> "#{row}"
    end
  end

  def next_coordinate_down(last_coordinate) do
    {:ok, {col, row}} = GameBoard.parse_coordinate(last_coordinate)
    new_row = row + 1
    if (new_row == 11) do
      provisional = next_coordinate_over(last_coordinate)
      {:ok, {new_col, _}} = GameBoard.parse_coordinate(provisional)
      new_col <> "1"
    else
      col <> "#{new_row}"
    end
  end

  defp initialize(board, [ship | rest_ships] = ships) do
    coordinate = get_random_coordinate([])
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

  defp get_random_coordinate(_) do
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
