defmodule AdmiralBehavior do
  @doc """
  The initialize function is where you'll create *your* game board, laying out
  the locations of your ships. Use the letter "A" to denote a squre occupied by
  a portion of the aircraft carrier, "B" for battleship, "C" for cruiser,
  "S" for submarine, and "D" for destroyer.
  Return the newly-created board as a list of ten ten-element lists. That is,
  a game board that looks like:

  |--+-+-+-+-+-+-+-+-+-+-|
  |  |A|B|C|D|E|F|G|H|I|J|
  |--+-+-+-+-+-+-+-+-+-+-|
  |1 |B| | | |A|A|A|A|A| |
  |2 |B| | | | | | | | | |
  |3 |B| |C|C|C| | | | | |
  |4 |B| | | | | | | | | |
  |5 | | | | | | | | |S| |
  |6 | | | | | | | | |S| |
  |7 | | | | | | | | |S| |
  |8 | | | | | | | | | | |
  |9 | | | | | |D|D| | | |
  |10| | | | | | | | | | |
  |--+-+-+-+-+-+-+-+-+-+-|

  Would be returned as:
  [
    ["B", "", "",  "",  "A", "A", "A", "A", "A", ""],
    ["B", "", "",  "",  "",  "",  "",  "",  "",  ""],
    ["B", "", "C", "C", "C", "",  "",  "",  "",  ""],
    ["B", "", "",  "",  "",  "",  "",  "",  "",  ""],
    ["",  "", "",  "",  "",  "",  "",  "",  "S", ""],
    ["",  "", "",  "",  "",  "",  "",  "",  "S", ""],
    ["",  "", "",  "",  "",  "",  "",  "",  "S", ""],
    ["",  "", "",  "",  "",  "",  "",  "",  "",  ""],
    ["",  "", "",  "",  "",  "D", "D", "",  "",  ""],
    ["",  "", "",  "",  "",  "",  "",  "",  "",  ""]
  ]

  Optionally, you may return a 2-element tuple with the first element being your
  game board, and the second element being any additional state you wish to
  track (i.e. the pid of a process you started while in `initialize/0`).
  """
  @callback initialize() :: [[String.t]] | {[[String.t]], any}

  @doc """
  The fire function is where you'll decide where to direct your next shot. The
  function parameters are a board showing your previous hits and misses, as well
  as a list of your shots and a list of results. The previous shots and results
  are sorted newest-to-oldest, so your most-recent shot and result is at the
  head of each list. Additionally, the state (if any) returned either from
  `initialize/0` or the previous call to `fire/4` is provided as the last
  parameter. If no state was provided, this parameter will be nil.

  You are to return the coordinate of your next shot, or optionally, a tuple
  with the next shot's coordinate as the first element, and your update state as
  the second element.

  An example board with 3 misses and 2 hits would look like:
  [
    ["",  "",  "",  "",  "",  "",  "",  "",  "",  ""],
    ["",  "",  "",  "",  "",  "",  "",  "",  "M", ""],
    ["",  "",  "",  "",  "",  "",  "",  "",  "",  ""],
    ["",  "",  "",  "",  "",  "",  "",  "",  "",  ""],
    ["",  "",  "",  "M", "",  "",  "",  "",  "",  ""],
    ["",  "",  "",  "",  "",  "",  "",  "",  "",  ""],
    ["",  "",  "",  "",  "",  "H", "",  "",  "",  ""],
    ["",  "M", "",  "",  "",  "H", "",  "",  "",  ""],
    ["",  "",  "",  "",  "",  "",  "",  "",  "",  ""],
    ["",  "",  "",  "",  "",  "",  "",  "",  "",  ""],
  ]
  """
  @callback fire([[String.t]], [GameBoard.coordinate], [GameBoard.fire_result], state :: any) :: GameBoard.coordinate | {GameBoard.coordinate, any}

  @doc """
  Provide your team name with this callback.
  """
  @callback team_name() :: String.t
end
