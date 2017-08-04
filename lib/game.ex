defmodule Game do
  @type ship_status :: {GameBoard.ship, hits_left :: non_neg_integer}
  @type team :: %{
    module: module,
    name: String.t,
    own_board: [[String.t]],
    enemy_board: [[String.t]],
    ships: [ship_status],
    shots_fired: [GameBoard.coordinate],
    shot_results: [GameBoard.fire_result],
    team_state: any
  }

  @spec setup_team(module) :: {:valid, team} | :invalid
  def setup_team(team_module) do
    with  {:ok, name} <- get_team_name(team_module),
          {:ok, {own_board, state}} <- call_initialize(team_module) do
      case GameBoard.validate_board(own_board) do
        :valid ->
          ship_statuses = [
            {:aircraft_carrier, 5},
            {:battleship, 4},
            {:cruiser, 3},
            {:destroyer, 2},
            {:submarine, 3}
          ]

          state = %{
            module: team_module,
            name: name,
            own_board: own_board,
            enemy_board: GameBoard.get_blank_board(),
            ships: ship_statuses,
            shots_fired: [],
            shot_results: [],
            team_state: state
          }

          {:valid, state}
        :invalid ->
          IO.puts "Team #{name} produced an invalid game board:"
          IO.puts "#{inspect own_board, pretty: true}"
          :invalid
      end
    else
      _ -> :invalid
    end
  end

  @spec play_game([module]) :: module
  def play_game([team1, team2]) do
    result1 = setup_team(team1)
    result2 = setup_team(team2)

    case {result1, result2} do
      {{:valid, team1_state}, {:valid, team2_state}} ->
        IO.puts "Team 1: #{team1_state.name} vs Team 2: #{team2_state.name}"
        {{:winner, winner}, _, turns} = play_round(team1_state, team2_state, 1, :team1)
        # Return the winning module
        IO.puts [IO.ANSI.green, "\nPlayer #{winner[:name]} wins in #{turns} turns!", IO.ANSI.default_color()]
        winner[:module]
      {:invalid, _} ->
        IO.puts [IO.ANSI.red(), "Team 1: #{inspect team1} produced an invalid board!"]
        IO.puts [IO.ANSI.blue(), "Team 2 wins by default."]

        team2
      {_, :invalid} ->
        IO.puts [IO.ANSI.blue(), "Team 2: #{inspect team2} produced an invalid board!"]
        IO.puts [IO.ANSI.red(), "Team 1 wins by default."]
        team1
    end
  end

  @spec play_round(team, team, pos_integer, :team1 | :team2) :: {{:winner, team}, {:loser, team}, pos_integer}
  def play_round(own, enemy, turn, team_turn) do
    IO.gets "Press enter to play turn #{turn}"
    IO.puts [IO.ANSI.home()]

    next_turn = case team_turn do
      :team1 -> :team2
      :team2 -> :team1
    end

    case handle_fire(own) do
      {:ok, coordinate, new_state} ->
        new_shots_fired = [coordinate | own[:shots_fired]]

        with  {:ok, {_column, _row}}  <- GameBoard.parse_coordinate(coordinate),
              {fire_result, enemy_ships} <- get_fire_result(coordinate, own, enemy) do
          new_enemy = Map.put(enemy, :ships, enemy_ships)
          new_shot_results = [fire_result | own[:shot_results]]
          new_enemy_board = update_enemy_board(own[:enemy_board], fire_result)

          new_own =
            own
            |> Map.put(:shots_fired, new_shots_fired)
            |> Map.put(:shot_results, new_shot_results)
            |> Map.put(:enemy_board, new_enemy_board)
            |> Map.put(:team_state, new_state)

          display_board(new_own, enemy, team_turn)
          display_shot_result(fire_result, own, enemy)

          if enemy_ships == [] do
            IO.puts "#{own[:name]} wins!"
            {{:winner, own}, {:loser, enemy}, turn}
          else
            play_round(new_enemy, new_own, turn + 1, next_turn)
          end
        else
          :invalid_coordinate ->
            new_shot_results = [{coordinate, :invalid_shot} | own[:shot_results]]

            new_own =
              own
              |> Map.put(:shots_fired, new_shots_fired)
              |> Map.put(:shot_results, new_shot_results)
              |> Map.put(:team_state, new_state)

            display_board(new_own, enemy, team_turn)
            IO.puts [IO.ANSI.red, "Team #{own[:name]} picked an invalid coordinate: #{coordinate}. Skipping turn..."]
            play_round(enemy, new_own, turn + 1, next_turn)
        end
      {:firing_error, error} ->
        display_board(own, enemy, team_turn)
        IO.puts [IO.ANSI.red, "Team #{own[:name]} call to fire/4 produced an error and have forfeited the game: #{inspect error}."]
        {{:winner, enemy}, {:loser, own}, turn}
    end
  end

  @spec handle_fire(team) :: {:ok, GameBoard.coordinate, new_state :: any} | {:firing_error, any}
  def handle_fire(team) do
    module = team[:module]
    args = [team[:enemy_board], team[:shots_fired], team[:shot_results], team[:team_state]]
    try do
      {coords, state} = case apply(module, :fire, args) do
        {coordinate, new_state} -> {coordinate, new_state}
        coordinate -> {coordinate, team[:team_state]}
      end

      {:ok, coords, state}
    rescue e ->
      
      {:firing_error, e}
    end
  end

  @spec get_fire_result(GameBoard.coordinate, own :: team, enemy :: team) :: {GameBoard.fire_result, enemy_ships :: [ship_status]}
  def get_fire_result(coordinate, own, enemy) do
    ship_hit = if coordinate in own[:shots_fired] do
      # They've already fired at this location
      :duplicate
    else
      get_ship_hit(coordinate, enemy[:own_board])
    end

    case ship_hit do
      :duplicate -> {{coordinate, :duplicate_shot}, enemy[:ships]}
      nil -> {{coordinate, :miss}, enemy[:ships]}
      ship ->
        shots_left = Keyword.get(enemy[:ships], ship)
        if shots_left > 1 do
          new_status = Keyword.put(enemy[:ships], ship, shots_left - 1)
          {{coordinate, :hit}, new_status}
        else
          {{coordinate, {:hit, :sunk, ship}}, Keyword.delete(enemy[:ships], ship)}
        end
    end
  end

  @spec update_enemy_board(GameBoard.board, GameBoard.fire_result) :: GameBoard.board
  def update_enemy_board(enemy_board, {_coordinate, :duplicate_shot}), do: enemy_board
  def update_enemy_board(enemy_board, {_coordinate, :invalid_shot}), do: enemy_board
  def update_enemy_board(enemy_board, {coordinate, result}) do
    {:ok, {col, row}} = GameBoard.parse_coordinate(coordinate)
    {:ok, row_index} = GameBoard.get_row_index(row)
    {:ok, row_vals} = GameBoard.get_row(enemy_board, row)
    {:ok, column_index} = GameBoard.get_column_index(col)

    result_symbol = case result do
      :miss -> "M"
      _ -> "H"
    end

    {first, [_val | rest]} = Enum.split(row_vals, column_index)

    new_row = first ++ [result_symbol] ++ rest

    {first, [_old_row | rest]} = Enum.split(enemy_board, row_index)
    first ++ [new_row] ++ rest
  end

  def update_enemy_board(enemy_board, _), do: enemy_board

  @spec get_ship_hit(GameBoard.coordinate, GameBoard.board) :: GameBoard.ship | nil
  def get_ship_hit(coordinate, enemy_board) do
    {:ok, {col, row}} = GameBoard.parse_coordinate(coordinate)
    {:ok, col} = GameBoard.get_column(enemy_board, col)
    {:ok, row_index} = GameBoard.get_row_index(row)

    case Enum.at(col, row_index) do
      "A" -> :aircraft_carrier
      "B" -> :battleship
      "C" -> :cruiser
      "D" -> :destroyer
      "S" -> :submarine
      _ -> nil
    end
  end

  @spec call_initialize(module) :: {:ok, {GameBoard.board, any}} | {:initialize_error, any}
  defp call_initialize(team_module) do
    try do
      {board, state} = case apply(team_module, :initialize, []) do
        {board, state} -> {board, state}
        board -> {board, nil}
      end

      {:ok, {board, state}}
    rescue
      e ->
        IO.puts "Team module #{inspect team_module} raised #{inspect e} when calling initialize/0."
        {:initialize_error, e}
    catch
      e ->
        IO.puts "Team module #{inspect team_module} threw #{inspect e} when calling initialize/0."
        {:initialize_error, e}
    end
  end

  @spec get_team_name(module) :: {:ok, String.t} | {:team_name_error, any}
  defp get_team_name(team_module) do
    try do
      name = apply(team_module, :team_name, [])
      {:ok, name}
    rescue
      e ->
        IO.puts "Team module #{inspect team_module} raised #{inspect e} when calling team_name/0."
        {:team_name_error, e}
    catch
      e ->
        IO.puts "Team module #{inspect team_module} exited with #{inspect e} when calling team_name/0."
        {:team_name_error, e}
    end
  end

  defp display_board(own, enemy, :team1), do: BoardPrinter.display_boards(own, enemy)
  defp display_board(own, enemy, :team2), do: BoardPrinter.display_boards(enemy, own)

  defp display_shot_result({coord, :miss}, own, _enemy) do
    IO.puts [
      "Player ", IO.ANSI.green(), own.name, IO.ANSI.default_color(),
      " fired at coordinate #{coord} and MISSED."]
  end

  defp display_shot_result({coord, :hit}, own, _enemy) do
    IO.puts [
      "Player ", IO.ANSI.green(), own.name, IO.ANSI.default_color(),
      " fired at coordinate #{coord} and SCORED A HIT!"]
  end

  defp display_shot_result({coord, {:hit, :sunk, ship}}, own, enemy) do
    IO.puts [
      "Player ", IO.ANSI.green(), own.name, IO.ANSI.default_color(),
      " fired at coordinate #{coord} and SUNK ",
      IO.ANSI.green(), enemy.name, "'s ", IO.ANSI.default_color(), 
      "#{inspect ship}!"]
  end

  defp display_shot_result({coord, other}, own, _enemy) do
    result = case other do
      :duplicate_shot -> "A DUPLICATE SHOT"
      :invalid_shot -> "AN INVALID COORDINATE"
      other -> "A #{inspect(other)}"
    end

    IO.puts [
      "Player ", IO.ANSI.green(), own.name, IO.ANSI.default_color(),
      " fired at coordinate #{coord} but that was ",
      IO.ANSI.red(), result, IO.ANSI.default_color()]
  end
end
