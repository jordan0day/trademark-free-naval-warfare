defmodule GameBoard do
  @typedoc """
  A coordinate is a combination of the column and row marking, such as "A1" or
  "J10".
  """
  @type coordinate :: String.t

  @type ship :: :aircraft_carrier | :battleship | :cruiser | :submarine | :destroyer

  @type fire_result :: {coordinate, :miss | :hit | {:hit, :sunk, ship}}

  @valid_columns ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
  @valid_rows [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

  @doc """
  Returns an empty 10x10 game board.
  """
  def get_blank_board() do
    [
      ["", "", "", "", "", "", "", "", "", ""],
      ["", "", "", "", "", "", "", "", "", ""],
      ["", "", "", "", "", "", "", "", "", ""],
      ["", "", "", "", "", "", "", "", "", ""],
      ["", "", "", "", "", "", "", "", "", ""],
      ["", "", "", "", "", "", "", "", "", ""],
      ["", "", "", "", "", "", "", "", "", ""],
      ["", "", "", "", "", "", "", "", "", ""],
      ["", "", "", "", "", "", "", "", "", ""],
      ["", "", "", "", "", "", "", "", "", ""],
    ]
  end

  def place_ship(board, :aircraft_carrier, coordinate, :vertical) do
  end

  def place_ship(board, ship_type, coordinate, direction) do
  end

  @spec parse_coordinate(String.t) :: {String.t, non_neg_integer} | :bad_coordinate
  def parse_coordinate(coordinate) do
    coordinate = String.upcase(coordinate)
    
    regex = ~r/^(?'column'[a-zA-Z])(?'row'\d+)$/
    case Regex.named_captures(regex, coordinate) do
      %{"column" => col, "row" => row} = coords when col in @valid_columns and row in @valid_rows ->
        {col, row}
    end
  end
end