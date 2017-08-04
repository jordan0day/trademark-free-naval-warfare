defmodule ZeroDayAdmiral do
  @behaviour AdmiralBehavior

  @all_coordinates for row <- 1..10, col <- ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"], do: "#{col}#{row}"
  def initialize() do
    RandomAdmiral.initialize()
  end

  def fire(_, shots, shot_results, _state) do
    [last_shot | rest] = shot_results

    case last_shot do
      {coordinate, :hit} ->

      _ ->
        random_shot(history)
    end
  end

  defp random_nearby(current_coord, previous_results) do
    [last_shot | rest] = previous_results
    case last_shot do
      {coord, :hit} ->
        {:ok, current} = GameBoard.parse_coordinate(current_coord)
        {:ok, last} = GameBoard.parse_coordinate(coord)
        orientation = orientation(current, last)

    end
  end

  def get_nearby_rows(1), do: [2]
  def get_nearby_rows(10), do: [9]
  def get_nearby_rows(row), do: [(row - 1), (row + 1)] 

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

  def adjacent_coordinates({col, row}, rows, cols, :horizontal) do
    adjacent_horizonal_coordinates(row, cols)
  end
  def adjacent_coordinates({col, row}, rows, cols, :vertical) do
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