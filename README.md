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

### Functions to implement
`team_name/0` - This one's easy. It's the name you want displayed at the top of
the screen during the game.

`initialize/0` - This is the function called at the beginning of the game where
you'll set up your game board, as well as set up an initial state you might want
to keep track of.

`fire/4` - This is the main driver of your game module. Here you'll choose what
coordinate at which to fire next. The first argument is a board showing your
previous shots, with "H" and "M" denoting previous shot results. The second
argument is the list of previous shoot coordinates, order from newest to
oldest (so the head of the list is the shot from the previous round). The third
argument is the list of results, with a format like

`{"A1", :miss}`

`{"B2", :hit}`

`{"C3", {:hit, :sunk, :battleship}}`

`{"A1", :duplicate_shot}`

`{"Z99", :invalid_shot}`

This list, like the list of previous shots, is sorted newest-to-oldest. As the
coordinate is included in the result tuple, the list of previous shots (the 2nd
argument) is a bit superflouous, but I wasn't sure which form people would
prefer.

The fourth and final argument to `fire/4` is the _optional_ state value you
previously returned, either from `initialize/0` or the previous call to `fire/4`.

The return value of `fire/4` is either just a coordinate (like `"A1"`), or a
tuple with the coordinate and the new state you want to track, like
`{"A1", %{total_shots_ive_taken: 3}}`.

## Testing Your Code
You can test your admiral's code by playing it against the two built-in
admirals, `RandomAdmiral` and `SmarterRandomAdmiral`. Trigger a one-off game
via `$ mix run -e 'TFNW.start_one("random.exs", "[your filename].exs")'`.

By the time you're done, you should be able to beat `random.exs` *every* time.
You should also be able to beat `smarter_random.exs` almost all the time, but
it might get lucky once in a while.

