defmodule BoardPrinterTest do
  use ExUnit.Case

  doctest BoardPrinter
  import BoardPrinter

  setup do
    team1_board = [
      ["A", "",  "",  "",  "",  "", "",  "",  "",  ""],
      ["A", "",  "",  "",  "",  "", "C", "C", "C", ""],
      ["A", "",  "",  "",  "",  "", "",  "",  "",  ""],
      ["A", "",  "",  "",  "D", "", "",  "",  "",  ""],
      ["A", "",  "",  "",  "D", "", "",  "",  "",  ""],
      ["",  "",  "",  "",  "",  "", "",  "",  "",  ""],
      ["",  "B", "B", "B", "B", "", "",  "",  "",  ""],
      ["",  "",  "",  "",  "",  "", "",  "",  "",  "S"],
      ["",  "",  "",  "",  "",  "", "",  "",  "",  "S"],
      ["",  "",  "",  "",  "",  "", "",  "",  "",  "S"],
    ]

    team2_board = [
      ["", "", "", "",  "", "",  "",  "",  "",  ""],
      ["", "", "", "A", "", "",  "",  "",  "B", ""],
      ["", "", "", "A", "", "D", "S", "",  "B", ""],
      ["", "", "", "A", "", "D", "S", "",  "B", ""],
      ["", "", "", "A", "", "",  "S", "",  "B", ""],
      ["", "", "", "A", "", "",  "",  "",  "",  ""],
      ["", "", "", "",  "", "",  "",  "",  "",  ""],
      ["", "", "", "",  "", "",  "",  "",  "",  ""],
      ["", "", "", "",  "", "",  "",  "C", "C", "C"],
      ["", "", "", "",  "", "",  "",  "",  "",  ""]
    ]

    team1 = %{
      name: "Test Team 1",
      own_board: team1_board,
      enemy_board: GameBoard.get_blank_board()
    }

    team2 = %{
      name: "Team 2 Test ABCDEF",
      own_board: team2_board,
      enemy_board: GameBoard.get_blank_board()
    }

    {:ok, team1: team1, team2: team2}
  end

  describe "team_header" do
    test "centers an even-length team name" do
      team = %{name: "even"}

      assert "          even          " == team_header(team)
    end

    test "centers an odd-length team name" do
      team = %{name: "odd"}

      assert "          odd           " == team_header(team)
    end
  end

  describe "header line" do
    test "prints team names correctly offset" do
      team1 = %{name: "team 1"}
      team2 = %{name: "team 2 longer name"}

      expected = "         team 1          vs    team 2 longer name   "
      assert expected == team_header_line(team1, team2)
    end

    test "prints team names correctly offset with an odd-length team name" do
      team1 = %{name: "team 1 okay"}
      team2 = %{name: "team 2 not ok!"}

      expected = "      team 1 okay        vs      team 2 not ok!     "
      assert expected == team_header_line(team1, team2)
    end
  end

  describe "get_columns" do
    own =   ["A", "", "", "",  "", "", "", "", "D", "D"]
    enemy = ["",  "", "", "M", "", "", "", "", "",  "H"]

    expected = [
      [IO.ANSI.white_background(), IO.ANSI.black(), "A", IO.ANSI.default_background(), IO.ANSI.default_color()],
      [" "],
      [" "],
      [IO.ANSI.white_background(), IO.ANSI.black(), "*", IO.ANSI.default_background(), IO.ANSI.default_color()],
      [" "],
      [" "],
      [" "],
      [" "],
      [IO.ANSI.white_background(), IO.ANSI.black(), "D", IO.ANSI.default_background(), IO.ANSI.default_color()],
      [IO.ANSI.red_background(), IO.ANSI.black(), "*", IO.ANSI.default_background(), IO.ANSI.default_color()]
    ]

    assert expected == get_columns(own, enemy)
  end
end
