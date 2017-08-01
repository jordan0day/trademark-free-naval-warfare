defmodule GameBoardTest do
  use ExUnit.Case

  doctest GameBoard

  import GameBoard

  setup do
      sample_board = [
        ["",  "",  "",  "",  "",  "", "",  "",  "",  ""],
        ["A", "",  "",  "",  "",  "", "C", "C", "C", ""],
        ["A", "",  "",  "",  "",  "", "",  "",  "",  ""],
        ["A", "",  "",  "",  "D", "", "",  "",  "",  ""],
        ["A", "",  "",  "",  "D", "", "",  "",  "",  ""],
        ["A", "",  "",  "",  "",  "", "",  "",  "",  ""],
        ["",  "B", "B", "B", "B", "", "",  "",  "",  ""],
        ["",  "",  "",  "",  "",  "", "",  "",  "",  "S"],
        ["",  "",  "",  "",  "",  "", "",  "",  "",  "S"],
        ["",  "",  "",  "",  "",  "", "",  "",  "",  "S"],
      ]

      blank_board = [
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
    {:ok, sample_board: sample_board, blank_board: blank_board}
  end

  test "get_blank_board" do
    board = get_blank_board()

    assert length(board) > 0
    Enum.each(board, fn row ->
      assert Enum.all?(row, &(&1 == ""))
    end)
  end

  describe "get_column" do
    test "returns `:invalid_column` for an out-of-range column", %{sample_board: board} do
      assert :invalid_column == get_column(board, "K")
    end

    test "returns `:invalid_column` for an invalid column specifier", %{sample_board: board} do
      assert :invalid_column == get_column(board, 1)
    end

    test "returns the first column", %{sample_board: board} do
      expected = ["", "A", "A", "A", "A", "A", "", "", "", ""]
      assert {:ok, expected} == get_column(board, "A")
    end

    test "returns the last column", %{sample_board: board} do
      expected = ["", "", "", "", "", "", "", "S", "S", "S"]
      assert {:ok, expected} == get_column(board, "J")
    end

    test "returns a column from the middle of the board", %{sample_board: board} do
      expected = ["", "", "", "D", "D", "", "B", "", "", ""]
      assert {:ok, expected} == get_column(board, "E")
    end
  end

  describe "get_row" do
    test "returns `:invalid_row` for an out-of-range row", %{sample_board: board} do
      assert :invalid_row == get_row(board, 11)
    end

    test "returns `:invalid_row` for a zero row number", %{sample_board: board} do
      assert :invalid_row == get_row(board, 0)
    end

    test "returns `:invalid_row` for a negative row number", %{sample_board: board} do
      assert :invalid_row == get_row(board, -1)
    end

    test "returns `:invalid_row` for an invalid row specifier", %{sample_board: board} do
      assert :invalid_row == get_row(board, "A")
    end

    test "returns the first row", %{sample_board: board} do
      expected = ["", "",  "",  "",  "",  "", "", "", "", ""]
      assert {:ok, expected} == get_row(board, 1)
    end

    test "returns the last row", %{sample_board: board} do
      expected = ["", "",  "",  "",  "",  "", "", "", "", "S"]
      assert {:ok, expected} == get_row(board, 10)
    end

    test "returns a row from the middle of the board", %{sample_board: board} do
      expected = ["A", "",  "",  "",  "",  "", "C", "C", "C", ""]
      assert {:ok, expected} == get_row(board, 2)
    end
  end

  describe "parse_coordinate" do
    test "returns `:invalid_coordinate` for an out-of-order coordinate" do
      assert :invalid_coordinate == parse_coordinate("10A")
    end

    test "returns `:invalid_coordinate` for an out-of-range row" do
      assert :invalid_coordinate == parse_coordinate("A13")
    end

    test "returns `:invalid_coordinate` for an out-of-range column" do
      assert :invalid_coordinate == parse_coordinate("Z2")
    end

    test "returns `{:ok, {col, row}}` for a valid coordinate" do
      assert {:ok, {"A", 7}} == parse_coordinate("A7")
    end

    test "returns `{:ok, {col, row}}` for a valid coordinate with a two-digit row number" do
      assert {:ok, {"A", 10}} == parse_coordinate("A10")
    end
  end

  describe "place_ship" do
    test "placing any ship horizontally anywhere in the last column is not allowed", %{blank_board: board} do
      assert {:error, :invalid_position} = place_ship(board, :aircraft_carrier, "J1", :horizontal)
      assert {:error, :invalid_position} = place_ship(board, :battleship, "J3", :horizontal)
      assert {:error, :invalid_position} = place_ship(board, :cruiser, "J6", :horizontal)
      assert {:error, :invalid_position} = place_ship(board, :destroyer, "J8", :horizontal)
      assert {:error, :invalid_position} = place_ship(board, :submarine, "J10", :horizontal)
    end

    test "placing any ship vertically anywhere in the last row is not allowed", %{blank_board: board} do
      assert {:error, :invalid_position} = place_ship(board, :aircraft_carrier, "A10", :vertical)
      assert {:error, :invalid_position} = place_ship(board, :battleship, "C10", :vertical)
      assert {:error, :invalid_position} = place_ship(board, :cruiser, "E10", :vertical)
      assert {:error, :invalid_position} = place_ship(board, :destroyer, "G10", :vertical)
      assert {:error, :invalid_position} = place_ship(board, :submarine, "J10", :vertical)
    end

    test "returns `{:error, :invalid_coordinate}` for a bad coordinate row value", %{blank_board: board} do
      assert {:error, :invalid_coordinate} = place_ship(board, :cruiser, "A13", :horizontal)
    end

    test "returns `{:error, :invalid_coordinate}` for a bad coordinate column value", %{blank_board: board} do
      assert {:error, :invalid_coordinate} = place_ship(board, :cruiser, "Z1", :vertical)
    end

    test "returns `{:error, :invalid_ship}` for a bad ship type", %{blank_board: board} do
      assert {:error, :invalid_ship} = place_ship(board, :frigate, "A1", :horizontal)
    end

    test "succesfully placing a ship horizontally at A1 on a blank board", %{blank_board: board} do
      expected = [
        ["A", "A", "A", "A", "A", "", "", "", "", ""],
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

      assert expected == place_ship(board, :aircraft_carrier, "A1", :horizontal)
    end

    test "succesfully placing a ship horizontally at F1 on a blank board", %{blank_board: board} do
      expected = [
        ["", "", "", "", "", "A", "A", "A", "A", "A"],
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

      assert expected == place_ship(board, :aircraft_carrier, "F1", :horizontal)
    end

    test "succesfully placing a ship horizontally at A10 on a blank board", %{blank_board: board} do
      expected = [
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["A", "A", "A", "A", "A", "", "", "", "", ""],
      ]

      assert expected == place_ship(board, :aircraft_carrier, "A10", :horizontal)
    end

    test "succesfully placing a ship horizontally at F10 on a blank board", %{blank_board: board} do
      expected = [
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "A", "A", "A", "A", "A"],
      ]

      assert expected == place_ship(board, :aircraft_carrier, "F10", :horizontal)
    end

    test "succesfully placing a ship vertically at A1 on a blank board", %{blank_board: board} do
      expected = [
        ["A", "", "", "", "", "", "", "", "", ""],
        ["A", "", "", "", "", "", "", "", "", ""],
        ["A", "", "", "", "", "", "", "", "", ""],
        ["A", "", "", "", "", "", "", "", "", ""],
        ["A", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
      ]

      assert expected == place_ship(board, :aircraft_carrier, "A1", :vertical)
    end

    test "succesfully placing a ship vertically at J1 on a blank board", %{blank_board: board} do
      expected = [
        ["", "", "", "", "", "", "", "", "", "A"],
        ["", "", "", "", "", "", "", "", "", "A"],
        ["", "", "", "", "", "", "", "", "", "A"],
        ["", "", "", "", "", "", "", "", "", "A"],
        ["", "", "", "", "", "", "", "", "", "A"],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
      ]

      assert expected == place_ship(board, :aircraft_carrier, "J1", :vertical)
    end

    test "succesfully placing a ship vertically at A6 on a blank board", %{blank_board: board} do
      expected = [
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["A", "", "", "", "", "", "", "", "", ""],
        ["A", "", "", "", "", "", "", "", "", ""],
        ["A", "", "", "", "", "", "", "", "", ""],
        ["A", "", "", "", "", "", "", "", "", ""],
        ["A", "", "", "", "", "", "", "", "", ""],
      ]

      assert expected == place_ship(board, :aircraft_carrier, "A6", :vertical)
    end

    test "succesfully placing a ship vertically at J6 on a blank board", %{blank_board: board} do
      expected = [
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", ""],
        ["", "", "", "", "", "", "", "", "", "A"],
        ["", "", "", "", "", "", "", "", "", "A"],
        ["", "", "", "", "", "", "", "", "", "A"],
        ["", "", "", "", "", "", "", "", "", "A"],
        ["", "", "", "", "", "", "", "", "", "A"],
      ]

      assert expected == place_ship(board, :aircraft_carrier, "J6", :vertical)
    end
  end

  describe "place_ship/4 position_occupied tests" do
    # This would be an awfully good place for some code-generated tests I think.
    # Property-based testing maybe?
    test "A1 horizontal, then A1 vertical", %{blank_board: board} do
      new_board = place_ship(board, :battleship, "A1", :horizontal)
      assert {:error, :position_occupied} = place_ship(new_board, :cruiser, "A1", :vertical)
    end

    test "A1 horizontal, then B1 vertical", %{blank_board: board} do
      new_board = place_ship(board, :battleship, "A1", :horizontal)
      assert {:error, :position_occupied} = place_ship(new_board, :cruiser, "B1", :vertical)
    end

    test "A2 horizontal, then B1 vertical", %{blank_board: board} do
      new_board = place_ship(board, :battleship, "A2", :horizontal)
      assert {:error, :position_occupied} = place_ship(new_board, :cruiser, "B1", :vertical)
    end

    test "A2 horizontal, then B2 vertical", %{blank_board: board} do
      new_board = place_ship(board, :battleship, "A2", :horizontal)
      assert {:error, :position_occupied} = place_ship(new_board, :cruiser, "B2", :vertical)
    end

    test "A1 vertical, then A1 horizontal", %{blank_board: board} do
      new_board = place_ship(board, :battleship, "A1", :vertical)
      assert {:error, :position_occupied} = place_ship(new_board, :cruiser, "A1", :horizontal)
    end

    test "A1 vertical, then A2 horizontal", %{blank_board: board} do
      new_board = place_ship(board, :battleship, "A1", :vertical)
      assert {:error, :position_occupied} = place_ship(new_board, :cruiser, "A2", :horizontal)
    end

    test "A2 vertical, then A2 horizontal", %{blank_board: board} do
      new_board = place_ship(board, :battleship, "A2", :vertical)
      assert {:error, :position_occupied} = place_ship(new_board, :cruiser, "A2", :horizontal)
    end
  end

  describe "validate board" do
    test "valid board", %{sample_board: board} do
      assert :valid = validate_board(board)
    end

    test "submarine occupying only two spaces", %{sample_board: board} do
      new_board = update_board_at(board, 9, 9, "")
      assert :invalid == validate_board(new_board)
    end

    test "battleship occupying five spaces", %{sample_board: board} do
      new_board = update_board_at(board, 6, 0, "B")
      assert :invalid == validate_board(new_board)
    end

    test "submarine split vertically", %{sample_board: board} do
      new_board =
        board
        |> update_board_at(7, 9, "")
        |> update_board_at(0, 9, "S")

      assert :invalid == validate_board(new_board)
    end

    test "battleship split horizontally", %{sample_board: board} do
      new_board =
        board
        |> update_board_at(6, 4, "")
        |> update_board_at(6, 3, "")
        |> update_board_at(6, 0, "B")
        |> update_board_at(6, 9, "B")

      assert :invalid == validate_board(new_board)
    end
  end

  defp update_board_at(board, row_index, column_index, new_value) do
    {first_rows, [row | rest_rows]} = Enum.split(board, row_index)
    {first_cols, [_col | rest_cols]} = Enum.split(row, column_index)

    new_row = first_cols ++ [new_value | rest_cols]
    first_rows ++ [new_row | rest_rows]
  end
end
