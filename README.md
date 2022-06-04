# RadarDefender

RadarDefender is a simple game made using GameZero.jl as an entry for the GameJam held in the Julia discord server.

# Requirements
- GameZero.jl
- Colors.jl

# Objective

Defend your base against the endless horde of invaders.

# Controls
- UP/DOWN to move the cross-hair radially. LEFT/RIGHT to move it along a circular arc.
- TYPE the letters and press ENTER to submit the launch code and attack an invader.
- HOLD 1 to slow down speed (for precise motion) and 2 to speed up.
- Everytime you reach a COMBO of 5 hits, you gain a force-field ability (bottom right) that can wipe out the entire grid, using SPACE key.

# Known Bugs
- The `schedule_once()` functions from GameZero.jl is used to introduce delays in animations like the force-field ability, or wave progression. This seems buggy and sometimes gets stuck midway. I have no other workaround than to restart the game and hope it doesn't happen again.

# Remarks
- I got this idea for the game on the morning of 4th June 2022, with the deadline for the GameJam being 5th June 2022. So, the result is a ton of spagetti code thats unorganized and extremely messy. I might try to clean it up after the GameJam judging ends, to serve as an example game for GameZero.jl. 