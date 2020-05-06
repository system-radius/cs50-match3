--[[
  A remake of a Match 3 game implemented in Lua using Love2D as framework.

  Author: Darius Orias
]]
require 'src/Dependencies'

-- Some local variables
local LOOP_BACK = 512
local BACKGROUND_SCROLL = 50
local backgroundX = 0

local currentMusic = 3

--[[
  Standard function under the Love2D framework.
  This is called at the very start of launching the game. All initializations to be used
    throughout the game is done here.
]]
function love:load()

  -- misc setup
  love.graphics.setDefaultFilter('nearest', 'nearest')
  math.randomseed(os.time())

  love.window.setTitle('Match 3')
  
  -- load the textures / quads
  gTextures = {
    ['background'] = love.graphics.newImage('graphics/background.png'),
    ['tiles'] = love.graphics.newImage('graphics/match3.png'),
    ['sp'] = love.graphics.newImage('graphics/shiningParticle.png'),
  }

  -- Contains the coordinates for the rows and columns of the tiles to be loaded from the 'tiles' sprite sheet.
  local colors = {
    [1] = {x = RED_X, y = RED_Y},
    [2] = {x = ORANGE_X, y = ORANGE_Y},
    [3] = {x = YELLOW_X, y = YELLOW_Y},
    [4] = {x = GREEN_X, y = GREEN_Y},
    [5] = {x = BLUE_X, y = BLUE_Y},
    [6] = {x = GRAY_X, y = GRAY_Y},
    [7] = {x = VIOLET_X, y = VIOLET_Y}
  }

  local limit = 5
  gFrames = {}
  for i = 1, #colors do
    gFrames[i] = GenerateRowQuads(gTextures['tiles'], TILE_WIDTH, TILE_HEIGHT, colors[i].x, colors[i].y, limit)
  end

  -- load the fonts
  gFonts = {
    ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
    ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
    ['large'] = love.graphics.newFont('fonts/font.ttf', 32)
  }

  -- load the sounds
  gSounds = {
    ['clock'] = love.audio.newSource('sounds/clock.wav'),
    ['error'] = love.audio.newSource('sounds/error.wav'),
    ['game-over'] = love.audio.newSource('sounds/game-over.wav'),
    ['match'] = love.audio.newSource('sounds/match.wav'),
    ['next-level'] = love.audio.newSource('sounds/next-level.wav'),
    ['select'] = love.audio.newSource('sounds/select.wav'),

    ['music1'] = love.audio.newSource('sounds/music.mp3'),
    ['music2'] = love.audio.newSource('sounds/music2.mp3'),
    ['music3'] = love.audio.newSource('sounds/music3.mp3')
  }

  cycleMusic()

  -- setup the window for push
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    vsync = true,
    fullscreen = false,
    resizable = true
  })

  -- load the states
  gStateMachine = StateMachine {
    ['start'] = function() return StartState() end,
    ['begin'] = function() return BeginState() end,
    ['play'] = function() return PlayState() end,
    ['summary'] = function() return SummaryState() end,
    ['game-over'] = function() return GameOverState() end
  }

  -- Set the state to start.
  gStateMachine:change('start')

  -- Initialize the recorders for the keys and buttons presses.
  love.keyboard.keysPressed = {}
  love.mouse.buttonsPressed = {}

end

--[[
  Standard function under the Love2D framework.
  This function is called everytime a key is pressed.
]]
function love.keypressed(key)
  love.keyboard.keysPressed[key] = true
end

--[[
  An extra function, allows retrieval of the key presses.
]]
function love.keyboard.wasPressed(key)
  return love.keyboard.keysPressed[key]
end

--[[
  Standard function under the Love2D framework.
  This function is called everytime a mouse button is pressed. This will then record that press
    along with the location the cursor is currently pointing. The coordinates are transformed
    in terms of push's virtual space.
]]
function love.mousepressed(mouseX, mouseY, button)

  local gameX, gameY = push:toGame(mouseX, mouseY)
  
  love.mouse.buttonsPressed[button] = {
    x = gameX, y = gameY
  }
  
  local buttonPress = love.mouse.buttonsPressed[button]

end

--[[
  An extra function, allows retrieval of the button presses from the mouse.
]]
function love.mouse.wasPressed(button)

  return love.mouse.buttonsPressed[button]
end

--[[
  Resize the screen. Standard function
]]
function love.resize(w, h)
  push:resize(w, h)
end

--[[
  Standard function under the Love2D framework.
  Update the current state, along with the timer. Also apply movement to the background image.
]]
function love.update(dt)
  Timer.update(dt)

  backgroundX = backgroundX - BACKGROUND_SCROLL * dt
  if backgroundX <= -LOOP_BACK then
    backgroundX = 0
  end

  gStateMachine:update(dt)

  if love.keyboard.wasPressed('escape') then
    love.event.quit()
  end

  -- reset the input
  love.keyboard.keysPressed = {}
  love.mouse.buttonsPressed = {}
end

--[[
  Standard function under the Love2D framework.
  Draw the moving background and the current state.
]]
function love.draw()
  push:start()

  love.graphics.draw(gTextures['background'], backgroundX, 0)
  gStateMachine:render()
  push:finish()
end

--[[
  A global function, allows colors to be reset to default.
]]
function resetColor()
  love.graphics.setColor(255, 255, 255, 255)
end

--[[
  A global function that allows the background music to change.
]]
function cycleMusic()

  local music = 'music' .. tostring(currentMusic)

  gSounds[music]:stop()
  currentMusic = currentMusic + 1 >= #gSounds and 1 or currentMusic + 1
  
  music = 'music' .. tostring(currentMusic)
  gSounds[music]:play()
  gSounds[music]:setLooping(true)

end