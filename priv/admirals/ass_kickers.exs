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

  def fire(enemy_board, previous_shots, [ { coord, :hit } | shot_results ], { orig_coord, direction }) do
    parsed_coord = Regex.named_captures(~r/^(?<letter>[A-J])(?<number>\d+)/, coord)

    up = direction_from_coord(parsed_coord, :up)
    down = direction_from_coord(parsed_coord, :down)
    left = direction_from_coord(parsed_coord, :left)
    right = direction_from_coord(parsed_coord, :right)

    { up || down || left || right, { orig_coord, direction }
  end

  def direction_from_coord(%{"letter" => letter, "number" => number}, :up) when number > 1 do
    {new_number, _} = Integer.parse(number)
    "#{letter}#{new_number - 1}"
  end
  def direction_from_coord(%{"letter" => letter, "number" => number}, :down) when number < 10 do
    {new_number, _} = Integer.parse(number)
    "#{letter}#{new_number + 1}"
  end
  def direction_from_coord(%{"letter" => letter, "number" => number}, :left) when letter > "A" do
    {new_number, _} = Integer.parse(number)
    "#{letter_from_number(number_from_letter(letter) - 1)}#{new_number}"
  end
  def direction_from_coord(%{"letter" => letter, "number" => number}, :right) when letter < "J" do
    {new_number, _} = Integer.parse(number)
    "#{letter_from_number(number_from_letter(letter) + 1)}#{new_number}"
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

  defp remove_previously_fired([], checkerboard_coords), do: checkerboard_coords
  defp remove_previously_fired([af | already_fired], checkerboard_coords) do
    remove_previously_fired(already_fired, List.delete(checkerboard_coords, af))
  end

  defp get_checkerboard_coords do
    x = for letter <- ?A..?J, do: << letter :: utf8 >>
    x
    |> Enum.map(fn letter -> Enum.map(1..10, fn n -> "#{letter}#{n}" end) end)
    |> Enum.with_index
    |> Enum.map(fn {list, number} -> if rem(number, 2) == 0, do: Enum.reverse(list), else: list end)
    |> List.flatten
    |> Enum.drop_every(2)
  end

  defp get_random_coordinate() do
    columns = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
    rows = 1..10

    col = Enum.random(columns)
    row = Enum.random(rows)

    "#{col}#{row}"
  end

  defp pick_random_direction() do
    case :rand.uniform(2) do
      1 -> :horizontal
      2 -> :vertical
    end
  end
end
