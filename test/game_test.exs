defmodule GameTest do
  use ExUnit.Case

  doctest Game

  import Game

  describe "get_ship_hit" do
    setup do
      board = [
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

      {:ok, board: board}
    end

    test "aircraft carrier", %{board: board} do
      coords = ["A1", "A2", "A3", "A4", "A5"]
      Enum.each(coords, fn coord ->
        assert :aircraft_carrier == get_ship_hit(coord, board)
      end)
    end

    test "battleship", %{board: board} do
      coords = ["B7", "C7", "D7", "E7"]
      Enum.each(coords, fn coord ->
        assert :battleship == get_ship_hit(coord, board)
      end)
    end

    test "cruiser", %{board: board} do
      coords = ["G2", "H2", "I2"]
      Enum.each(coords, fn coord ->
        assert :cruiser == get_ship_hit(coord, board)
      end)
    end

    test "destroyer", %{board: board} do
      coords = ["E4", "E5"]
      Enum.each(coords, fn coord ->
        assert :destroyer == get_ship_hit(coord, board)
      end)
    end

    test "submarine", %{board: board} do
      coords = ["J8", "J9", "J10"]
      Enum.each(coords, fn coord ->
        assert :submarine == get_ship_hit(coord, board)
      end)
    end

    test "empty spots", %{board: board} do
      coords = ["A6", "A7", "A8", "A9", "A10", "B1", "B2", "B3", "B4", "B5",
                "B6", "B8", "B9", "B10", "C1", "C2", "C2", "C3", "C4", "C5",
                "C6", "C8", "C9", "C10", "D1", "D2", "D3", "D4", "D5", "D6",
                "D8", "D9", "D10", "E1", "E2", "E3", "E6", "E8", "E9", "E10",
                "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10",
                "G1", "G3", "G4", "G5", "G6", "G7", "G8", "G9", "G10", "H1",
                "H3", "H4", "H5", "H6", "H7", "H8", "H9", "H10", "I1", "I3",
                "I4", "I5", "I6", "I7", "I8", "I9", "I10", "J1", "J2", "J3",
                "J4", "J5", "J6", "J7"]

      Enum.each(coords, fn coord ->
        assert nil == get_ship_hit(coord, board)
      end)
    end
  end

  describe "update enemy board" do
    setup do
      board = [["", "", ""],
               ["", "", ""],
               ["", "", ""]]
      {:ok, board: board}
    end

    test "A1 miss", %{board: board} do
      expected = [["M", "", ""],
                  ["", "", ""],
                  ["", "", ""]]

      assert expected == update_enemy_board(board, {"A1", :miss})
    end

    test "B2 hit", %{board: board} do
      expected = [["", "", ""],
                  ["", "H", ""],
                  ["", "", ""]]
      assert expected == update_enemy_board(board, {"B2", :hit})
    end

    test "C3 hit & sunk", %{board: board} do
      expected = [["", "", ""],
                  ["", "", ""],
                  ["", "", "H"]]
      assert expected == update_enemy_board(board, {"C3", {:hit, :sunk, :battleship}})
    end

    test "duplicate shot doesn't change the board", %{board: board} do
      assert board == update_enemy_board(board, {"A1", :duplicate_shot})
    end

    test "invalid shot doesn't change the board", %{board: board} do
      assert board == update_enemy_board(board, {"C2", :invalid_shot})
    end
  end

  describe "handle_fire" do
    defmodule TestModule do
      @behaviour AdmiralBehavior

      def fire(_, _, _, :raise) do
        raise "This is supposed to happen."
      end
      def fire(_enemy_board, _shots_fire, _shot_results, state) do
        pid = state
        coords = Agent.get_and_update(pid, fn [coord | rest] -> {coord, rest} end)
        {coords, :new_state}
      end
      def team_name(), do: "TestModule"
      def initialize(), do: []
    end

    setup do
      {:ok, pid} = Agent.start_link(fn -> [] end)

      team = %{
        module: TestModule,
        name: "TestModule",
        own_board: [["", ""], ["", ""]],
        enemy_board: [["", ""], ["", ""]],
        ships: [cruiser: 1],
        shots_fired: [],
        shot_results: [],
        team_state: pid
      }

      {:ok, team: team}
    end

    test "if callback function executes sucessfully, returns chosen coordinates and new state", %{team: team} do
      pid = team[:team_state]
      Agent.update(pid, fn _state -> ["A1"] end)
      assert {:ok, "A1", :new_state} = handle_fire(team)
    end

    test "if callback function raises an error, an error is returned", %{team: team} do
      team = Map.put(team, :team_state, :raise)

      assert {:firing_error, %RuntimeError{}} = handle_fire(team)
    end
  end

  describe "setup_team" do
    defmodule RaiseInTeamName do
      def team_name(), do: raise "Whoops!"
    end

    defmodule ThrowInTeamName do
      def team_name(), do: throw "Yikes!"
    end

    defmodule RaiseInInitialize do
      def team_name(), do: "RaiseInInitialize"
      def initialize(), do: raise "Whoops Part 2!"
    end

    defmodule ThrowInInitialize do
      def team_name(), do: "ThrowInInitialize"
      def initialize(), do: throw "Yikes Part 2!"
    end

    test "returns :invalid if an error is raised in the team_name/0 call" do
      assert :invalid == setup_team(RaiseInTeamName)
    end

    test "returns :invalid if a throw occurs in the team_name/0 call" do
      assert :invalid == setup_team(ThrowInTeamName)
    end

    test "returns :invalid if an error is raised in the initialize/0 call" do
      assert :invalid == setup_team(RaiseInInitialize)
    end

    test "returns :invalid if a throw occurs in the initialize/0 call" do
      assert :invalid == setup_team(ThrowInInitialize)
    end
  end
end
