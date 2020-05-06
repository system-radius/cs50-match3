-- Constant values to be used all throughout the game.

-- physical screen dimensions
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- virtual resolution dimensions
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

-- Tile-related constants. 
SCALE = 32
TILE_WIDTH = SCALE
TILE_HEIGHT = SCALE

-- Board-related constants
BOARD_WIDTH = 8
BOARD_HEIGHT = 8

BOARD_X = VIRTUAL_WIDTH - ((BOARD_WIDTH + 1) * TILE_WIDTH)
BOARD_Y = (VIRTUAL_HEIGHT / 2) - (BOARD_HEIGHT * TILE_HEIGHT) / 2

-- The row positions of the colors in the sprite sheet
RED_Y, RED_X = 2, 6
ORANGE_Y, ORANGE_X = 5, 6
YELLOW_Y, YELLOW_X = 0, 0
GREEN_Y, GREEN_X = 4, 0
BLUE_Y, BLUE_X = 5, 0
GRAY_Y, GRAY_X = 6, 6
VIOLET_Y, VIOLET_X = 8, 0

-- Scoring constants.
BASE_SCORE = 50
BASE_GOAL = 2500
MIN_MATCH = 3

TIMER_LIMIT = 60