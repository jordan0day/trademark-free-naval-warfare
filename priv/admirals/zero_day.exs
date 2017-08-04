defmodule ZeroDayAdmiral do
  @behaviour AdmiralBehavior

  @all_coordinates for row <- 1..10, col <- ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"], do: "#{col}#{row}"
  def initialize() do
    RandomAdmiral.initialize()
  end

  def fire(_, [], _, _state), do: random_shot([])

  def fire(_, previous_shots, shot_results, _state) do
    [last_shot | rest] = shot_results

    result = case last_shot do
      {coordinate, :hit} ->
        random_nearby(coordinate, rest, previous_shots)
      _ ->
        random_shot(previous_shots)
    end

    result
  end

  defp random_nearby(current_coord, _previous_results, previous_shots) do
    # [last_shot | rest] = previous_results
    # {coord, _result} = last_shot
    #case last_shot do
    #  {coord, :hit} ->
        #IO.puts "coord: #{inspect coord}"
        # {:ok, current} = GameBoard.parse_coordinate(current_coord)
        # {:ok, last} = GameBoard.parse_coordinate(coord)
        # orientation = orientation(current, last)

        {:ok, {col, row}} = GameBoard.parse_coordinate(current_coord)

        nearby_cols = get_nearby_cols(col)
        nearby_rows = get_nearby_rows(row)

        potential_coords = adjacent_coordinates({col, row}, nearby_rows, nearby_cols, :unknown)

        potential_coords
        |> Enum.reject(fn coordinate -> coordinate in previous_shots end)
        |> Enum.random
  end

  def get_nearby_rows(1), do: [2]
  def get_nearby_rows(10), do: [9]
  def get_nearby_rows(row) do
    [(row - 1), (row + 1)]
  end

  def get_nearby_cols("A"), do: ["B"]
  def get_nearby_cols("B"), do: ["A", "C"]
  def get_nearby_cols("C"), do: ["B", "D"]
  def get_nearby_cols("D"), do: ["C", "E"]
  def get_nearby_cols("E"), do: ["D", "F"]
  def get_nearby_cols("F"), do: ["E", "G"]
  def get_nearby_cols("G"), do: ["F", "H"]
  def get_nearby_cols("H"), do: ["G", "I"]
  def get_nearby_cols("I"), do: ["H", "J"]
  def get_nearby_cols("J"), do: ["I"]

  def adjacent_coordinates({_col, row}, _rows, cols, :horizontal) do
    adjacent_horizonal_coordinates(row, cols)
  end
  def adjacent_coordinates({col, _row}, rows, _cols, :vertical) do
    adjacent_vertical_coordinates(col, rows)
  end
  def adjacent_coordinates({col, row}, rows, cols, _) do
    adjacent_horizonal_coordinates(row, cols) ++ adjacent_vertical_coordinates(col, rows)
  end

  def adjacent_vertical_coordinates(col, rows) do
    for row <- rows, do: "#{col}#{row}"
  end
  def adjacent_horizonal_coordinates(row, cols) do
    for col <- cols, do: "#{col}#{row}"
  end

  def orientation({col, _}, {col, _}), do: :vertical
  def orientation({_, row}, {_, row}), do: :horizontal
  def orientation(_, _), do: :unknown

  defp random_shot(history) do
    @all_coordinates
    |> Enum.reject(fn c -> c in history end)
    |> Enum.shuffle()
    |> Enum.at(0)
  end

  def team_name() do
    "ZeroDay"
  end
end
