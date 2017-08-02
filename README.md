# Trademark-Free Naval Warfare!

## Overview

Trademark-free naval warfare is a game of strategy and luck. The game is played
on two 10x10 boards, with each player initializing their board before the game
begins. Initialization consists of placing the players 5 ships around their
board, and two ships cannot occupy the same square. The ships themselves are
classed as "Aircraft Carrier" (5x1), "Battleship" (4x1), "Cruiser" (3x1),
"Submarine" (3x1), and "Destroyer" (2x1). The gameboard axes are labeled 1-10 on
the vertical axis, and A-J on the horizontal axis.

Gameplay begins with player A selecting a coordinate on player B's board on
which to fire. Player B must inform player A whether their shot hit or missed
one of their ships. Then player B takes their turn selecting a coordinate and
firing. Gameplay continues like this until all the squares which a ship occupies
have been hit by enemy fire, at which point the player must announce the sinking
of the ship. The game is over once one of the players have lost all of their
ships.

Each player is allowed to keep track of their shots and the subsequent results,
and use this information when selecting where next to fire.

## Your task
Your job in Trademark-Free Naval Warfare is to create a module which implements
the AdmiralBehavior behavior. Create your module as an .exs file in the
`priv/admirals` folder, alongside the two provided implementations.

## Testing Your Code
You can test your admiral's code by playing it against the two built-in
admirals, `RandomAdmiral` and `SmarterRandomAdmiral`. Trigger a one-off game
via `$ mix run -e 'TFNW.start_one("random.exs", "[your filename].exs")'`.

By the time you're done, you should be able to beat `random.exs` *every* time.
You should also be able to beat `smarter_random.exs` almost all the time, but
it might get lucky once in a while.

