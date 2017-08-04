defmodule AssKickers do
  @behaviour AdmiralBehavior

  def team_name() do
    "Ass Kickers"
  end

  def initialize() do
    GameBoard.get_blank_board()
    |> GameBoard.place_ship(:cruiser, "D3", :vertical)
    |> GameBoard.place_ship(:aircraft_carrier, "E3", :horizontal)
    |> GameBoard.place_ship(:destroyer, "A4", :vertical)
    |> GameBoard.place_ship(:battleship, "H5", :vertical)
    |> GameBoard.place_ship(:submarine, "C6", :vertical)
  end


  # exhausted all directions
  def fire(enemy_board, previous_shots, shot_results, {orig_coord, []}) do
    fire(enemy_board, previous_shots, shot_results, nil)
  end

  # in this direction, we finally hit a blank
  def fire(enemy_board, previous_shots, [ { _, :miss } | rest_of_shots ], {orig_coord, [direction | rest]} = state) when direction != nil do
    fire(enemy_board, previous_shots, [ {orig_coord, :hit} | rest_of_shots ], {orig_coord, rest})
  end

  # work your way in all directions
  def fire(enemy_board, previous_shots, [ { last_coord, result } | rest_of_shots ] = shot_results, {orig_coord, [direction | rest]} = state) when direction != nil and (result == :hit or elem(result, 0) == :hit) do
    all_coords = get_all_coords()

    shots_fired =
      shot_results
      |> Enum.map(&(elem(&1, 0)))

    available = remove_previously_fired(shots_fired, all_coords)

    %{"letter" => letter, "number" => number} = Regex.named_captures(~r/^(?<letter>[A-J])(?<number>\d+)/, last_coord)
    {new_number, _} = Integer.parse(number)
    parsed_coord = %{"letter" => letter, "number" => new_number}

    next = direction_from_coord(parsed_coord, direction)

    if next in available do
      {next, state}
    else
      fire(enemy_board, previous_shots, [ {orig_coord, :hit} | rest_of_shots ], {orig_coord, rest})
    end
  end

  # original random hit
  def fire(enemy_board, previous_shots, [ { coord, :hit } | _ ] = shot_results, { coord, nil }) do
    fire(enemy_board, previous_shots, shot_results, { coord, [:up, :down, :left, :right] })
  end

  def fire(enemy_board, previous_shots, shot_results, _state) do
    checkerboard_coords = get_checkerboard_coords()

    shots_fired =
      shot_results
      |> Enum.map(&(elem(&1, 0)))

    random_coord =
      remove_previously_fired(shots_fired, checkerboard_coords)
      |> Enum.random 

   { random_coord, { random_coord, nil } }
  end

  defp remove_previously_fired([], coords), do: coords
  defp remove_previously_fired([af | already_fired], coords) do
    remove_previously_fired(already_fired, List.delete(coords, af))
  end

  defp get_all_coords do
    all_coords
    |> List.flatten
  end

  defp get_checkerboard_coords do
    all_coords
    |> Enum.with_index
    |> Enum.map(fn {list, number} -> if rem(number, 2) == 0, do: Enum.reverse(list), else: list end)
    |> List.flatten
    |> Enum.drop_every(2)
  end

  defp all_coords do
    x = for letter <- ?A..?J, do: << letter :: utf8 >>
    x
    |> Enum.map(fn letter -> Enum.map(1..10, fn n -> "#{letter}#{n}" end) end)
  end

  defp get_random_coordinate() do
    columns = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
    rows = 1..10

    col = Enum.random(columns)
    row = Enum.random(rows)

    "#{col}#{row}"
  end
  def direction_from_coord(%{"letter" => letter, "number" => number}, :up) when number > 1 do
    "#{letter}#{number - 1}"
  end
  def direction_from_coord(%{"letter" => letter, "number" => number}, :down) when number < 10 do
    "#{letter}#{number + 1}"
  end
  def direction_from_coord(%{"letter" => letter, "number" => number}, :left) when letter > "A" do
    "#{letter_from_number(number_from_letter(letter) - 1)}#{number}"
  end
  def direction_from_coord(%{"letter" => letter, "number" => number}, :right) when letter < "J" do
    "#{letter_from_number(number_from_letter(letter) + 1)}#{number}"
  end
  def direction_from_coord(_, _), do: nil

  def number_from_letter(letter) do
    x = %{
      "A" => 1,
      "B" => 2,
      "C" => 3,
      "D" => 4,
      "E" => 5,
      "F" => 6,
      "G" => 7,
      "H" => 8,
      "I" => 9,
      "J" => 10,
    }
    x[letter]
  end

  def letter_from_number(number) do
    x = %{
      1 => "A",
      2 => "B",
      3 => "C",
      4 => "D",
      5 => "E",
      6 => "F",
      7 => "G",
      8 => "H",
      9 => "I",
      10 => "J"
    }
    x[number]
  end

  defp pick_random_direction() do
    case :rand.uniform(2) do
      1 -> :horizontal
      2 -> :vertical
    end
  end
end
