defmodule BoardPrinter do
  # Example Board
  #          Team 1          vs          Team 2         
  # ------------------------    ------------------------
  # |  |A|B|C|D|E|F|G|H|I|J|    |  |A|B|C|D|E|F|G|H|I|J|
  # ------------------------    ------------------------
  # | 1|            B      |    | 1|                D D|
  # | 2|            B      |    | 2|                   |
  # | 3|A A A A A   B      |    | 3|        S          |
  # | 4|            B      |    | 4|        S          |
  # | 5|        D   B      |    | 5|        S          |
  # | 6|        D          |    | 6|A                  |
  # | 7|C C C              |    | 7|A                  |
  # | 8|                   |    | 8|A                  |
  # | 9|                   |    | 9|A                  |
  # |10|              S S S|    |10|A B B B B C C C    |
  # ------------------------    ------------------------

  @header_separator "------------------------    ------------------------"
  @header_columns   "|  |A|B|C|D|E|F|G|H|I|J|    |  |A|B|C|D|E|F|G|H|I|J|"

  @spec display_boards(Game.team, Game.team) :: :ok
  def display_boards(team1, team2) do
    teams_header = team_header_line(team1, team2)

    game_rows = get_game_rows_ansi(team1, team2)

    IO.puts IO.ANSI.clear()
    IO.puts [IO.ANSI.white(), teams_header]
    IO.puts @header_separator
    IO.puts @header_columns
    IO.puts @header_separator
    Enum.each(game_rows, &IO.puts/1)
    IO.puts [@header_separator, IO.ANSI.default_color()]
  end

  def team_header_line(team1, team2) do
    team1_header = team_header(team1)
    team2_header = team_header(team2)

    team1_header <> " vs " <> team2_header
  end

  def team_header(team) do
    # Protect against long names
    # 24 is the max name length
    {name, length} = case String.length(team.name) do
      x when x <= 24 -> {team.name, x}
      _ -> binary_part(team.name, 0, 24)
    end

    leading_space = trunc((24 - length) / 2)

    name
    |> String.pad_leading(leading_space + length)
    |> String.pad_trailing(24)
  end

  def get_game_rows_ansi(team1, team2) do
    rows = 1..10
    Enum.map(rows, fn row ->
      {:ok, team1_own} = GameBoard.get_row(team1.own_board, row)
      {:ok, team1_enemy} = GameBoard.get_row(team1.enemy_board, row)
      {:ok, team2_own} = GameBoard.get_row(team2.own_board, row)
      {:ok, team2_enemy} = GameBoard.get_row(team2.enemy_board, row)

      get_row_ansi(team1_own, team2_own, team1_enemy, team2_enemy, row)
    end)
  end

  def get_row_ansi(team1_own, team2_own, team1_enemy, team2_enemy, row) do
    row_string =
      row
      |> to_string()
      |> String.pad_leading(2)
    row_header = [IO.ANSI.white(), "|#{row_string}|"]
    row_footer = [IO.ANSI.white(), "|"]
    team1_columns =
      team1_own
      |> get_columns(team2_enemy)
      |> Enum.intersperse([" "])

    team2_columns =
      team2_own
      |> get_columns(team1_enemy)
      |> Enum.intersperse([" "])

    row_header ++ team1_columns ++ row_footer ++ ["    "] ++ row_header ++ team2_columns ++ row_footer
  end

  @spec get_columns([String.t], [String.t]) :: [[String.t]]
  def get_columns(own, enemy) do
    zipped = Enum.zip(own, enemy)

    Enum.map(zipped, fn
      {"", ""} -> [" "]
      {"", _} -> ["*"]
      {s, ""} -> [IO.ANSI.white_background(), IO.ANSI.black(), s, IO.ANSI.default_background(), IO.ANSI.default_color()]
      {_, _} -> [IO.ANSI.red_background(), IO.ANSI.black(), "*", IO.ANSI.default_background(), IO.ANSI.default_color()]
    end)
  end
end
