defmodule GameBoard do
  @typedoc """
  A coordinate is a combination of the column and row marking, such as "A1" or
  "J10".
  """
  @type board :: [[String.t]]
  @type coordinate :: String.t
  @type ship :: :aircraft_carrier | :battleship | :cruiser | :submarine | :destroyer
  @type fire_result :: {coordinate, :miss | :hit | {:hit, :sunk, ship}}

  @type column_update_error :: :invalid_position | :invalid_row | :invalid_ship | :position_occupied
  @type row_update_error :: :invalid_position | :invalid_column | :invalid_ship | :position_occupied

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

  @spec get_column(board, String.t) :: {:ok, [String.t]} | :invalid_column
  def get_column(board, column) when column in @valid_columns do
    {:ok, column_pos} = get_column_index(column)

    col =
      board
      |>  Enum.reduce([], fn (row, acc) ->
        col_val = Enum.at(row, column_pos)

        [col_val | acc]
      end)
      |> Enum.reverse

    {:ok, col}
  end
  def get_column(_, _), do: :invalid_column

  @spec get_row(board, pos_integer) :: {:ok, [String.t]} | :invalid_row
  def get_row(board, row) when row in @valid_rows do
    {:ok, row_index} = get_row_index(row)
    r = Enum.at(board, row_index)
    {:ok, r}
  end
  def get_row(_, _), do: :invalid_row

  @spec parse_coordinate(String.t) :: {:ok, {String.t, non_neg_integer}} | :invalid_coordinate
  def parse_coordinate(coordinate) do
    coordinate = String.upcase(coordinate)
    
    regex = ~r/^(?'column'[a-zA-Z])(?'row'\d+)$/
    with  %{"column" => col, "row" => row} <- Regex.named_captures(regex, coordinate),
          {row_num, ""} <- Integer.parse(row),
          true <- col in @valid_columns,
          true <- row_num in @valid_rows do
      {:ok, {col, row_num}}
    else
      _ -> :invalid_coordinate
    end
  end

  @spec place_ship(board, ship, coordinate, :horizontal | :vertical) :: board | {:error, :invalid_coordinate | column_update_error | row_update_error}
  def place_ship(board, ship_type, coordinate, :horizontal) do
    with  {:ok, {col, row}} <- parse_coordinate(coordinate),
          {:ok, row_vals} <- get_row(board, row),
          {:ok, new_row} <- update_row(row_vals, col, ship_type),
          new_board <- update_board_row(board, row, new_row) do
      new_board
    else
      {:error, reason} -> {:error, reason}
      reason -> {:error, reason}
    end
  end

  def place_ship(board, ship_type, coordinate, :vertical) do
    with  {:ok, {col, row}} <- parse_coordinate(coordinate),
          {:ok, column_vals} <- get_column(board, col),
          {:ok, new_column} <- update_column(column_vals, row, ship_type),
          new_board <- update_board_column(board, col, new_column) do
      new_board
    else
      {:error, reason} -> {:error, reason}
      reason -> {:error, reason}
    end
  end

  # Helpers
  @spec get_column_index(String.t) :: {:ok, non_neg_integer} | :invalid_column
  defp get_column_index(column) when column in @valid_columns do
    {:ok, Enum.find_index(@valid_columns, &(&1 == column))}
  end
  defp get_column_index(_), do: :invalid_column

  @spec get_row_index(pos_integer) :: {:ok, non_neg_integer} | :invalid_row
  defp get_row_index(row) when row in @valid_rows do
    {:ok, row - 1}
  end
  defp get_row_index(_), do: :invalid_row

  @spec update_board_column(board, String.t, [String.t]) :: {:ok, board}
  defp update_board_column(board, column_coord, new_column) do
    {:ok, column_number} = get_column_index(column_coord)

    board
    |> Enum.with_index()
    |> Enum.reduce([], fn ({row, index}, acc) ->
      {first, [_col_val | rest]} = Enum.split(row, column_number)
      new_column_val = Enum.at(new_column, index)

      acc ++ [first ++ [new_column_val] ++ rest]
    end)
  end

  defp update_board_row(board, row_coord, new_row) do
    {first, [_old_row | rest]} = Enum.split(board, row_coord - 1) # -1 here since the second arg is 0-based

    first ++ [new_row] ++ rest
  end

  @spec update_column([String.t], pos_integer, ship) :: {:ok, [String.t]} | {:error, column_update_error}
  defp update_column(col_vals, start_row, ship_type) do
    with  {:ok, size} <- ship_size(ship_type),
          {:ok, row_index} <- get_row_index(start_row),
          :ok <- validate_bounds(@valid_rows, row_index + size) do
      {first, rest} = Enum.split(col_vals, row_index)
      {position_vals, rest} = Enum.split(rest, size)

      if Enum.all?(position_vals, &(&1 == "")) do
        ship_symbol = ship_symbol(ship_type)
        ship_vals = List.duplicate(ship_symbol, size)

        new_col = first ++ ship_vals ++ rest
        {:ok, new_col}
      else
        {:error, :position_occupied}
      end
    else
      :invalid_ship -> {:error, :invalid_ship}
      :invalid_row -> {:error, :invalid_column}
      :out_of_bounds -> {:error, :invalid_position}
    end
  end

  @spec update_row([String.t], String.t, ship) :: {:ok, [String.t]} | {:error, row_update_error}
  defp update_row(row_vals, start_col, ship_type) do
    # IO.puts "Updating row: #{inspect row_vals} starting at column: #{start_col} with ship: #{inspect ship_type}"
    # IO.puts "Size: #{inspect ship_size(ship_type)}"
    # IO.puts "col index: #{inspect get_column_index(start_col)}"
    with  {:ok, size} <- ship_size(ship_type),
          {:ok, col_index} <- get_column_index(start_col),
          :ok <- validate_bounds(@valid_columns, col_index + size) do
      {first, rest} = Enum.split(row_vals, col_index)
      {position_vals, rest} = Enum.split(rest, size)

      if Enum.all?(position_vals, &(&1 == "")) do
        ship_symbol = ship_symbol(ship_type)
        ship_vals = List.duplicate(ship_symbol, size)

        new_row = first ++ ship_vals ++ rest
        {:ok, new_row}
      else
        {:error, :position_occupied}
      end
    else
      :invalid_ship -> {:error, :invalid_ship}
      :invalid_column -> {:error, :invalid_column}
      :out_of_bounds -> {:error, :invalid_position}
    end
  end

  @spec validate_bounds([any], pos_integer) :: :ok | :out_of_bounds
  defp validate_bounds(list, size) do
    if size > length(list) do
      :out_of_bounds
    else
      :ok
    end
  end

  @spec ship_size(ship) :: {:ok, 5 | 4 | 3 | 2} | :invalid_ship
  defp ship_size(:aircraft_carrier), do: {:ok, 5}
  defp ship_size(:battleship), do: {:ok, 4}
  defp ship_size(:cruiser), do: {:ok, 3}
  defp ship_size(:submarine), do: {:ok, 3}
  defp ship_size(:destroyer), do: {:ok, 2}
  defp ship_size(_), do: :invalid_ship

  @spec ship_symbol(ship) :: String.t
  defp ship_symbol(:aircraft_carrier), do: "A"
  defp ship_symbol(:battleship), do: "B"
  defp ship_symbol(:cruiser), do: "C"
  defp ship_symbol(:destroyer), do: "D"
  defp ship_symbol(:submarine), do: "S"
end