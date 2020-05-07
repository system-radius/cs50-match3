# cs50-match3
A derivation of Bejeweled / Candy Crush game.

The rate of shiny blocks spawning is 1 / 25. The rate is such because the game will be over quite soon if the spawn is more common. Besides, this game also makes use of the patterns to provide more clearing potential.

All pattern clears will require three or more consecutive tiles with the same pattern to be activated:
+ Cross pattern - (available at level 2+) this pattern will clear plain tiles of the same color.
+ Circle pattern - (available at level 3+) this will allow clearing entire row/s of tiles.
+ Square pattern - (available at level 4+) this will allow clearing entire column/s of tiles.
+ Triangle pattern - (available at level 5+) this combines the behavior of circle and square pattern clear.
+ Star pattern - (available at level 6+) this combines the behavior of triangle and cross pattern clear.

Clearing patterned tiles will also grant more points, so the per level score goal is raised to `level * 2500`.

See sample gameplay here: https://www.youtube.com/watch?v=F9rsAH_i1qc
