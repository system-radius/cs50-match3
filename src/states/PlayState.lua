PlayState = Class{__includes = BaseState}

--[[
  Initialize this state.
]]
function PlayState:init()

  -- The current highlighted tile.
  self.highlighted = nil

  -- Flag for whether there is a selected tile.
  self.hasHighlight = false

  -- For transitions going into the next state.
  self.transitionAlpha = 0

  -- Flag for reading inputs.
  self.readInputs = true

  -- Flag if the player can still play.
  self.gameOver = false

  -- The selector object.
  self.selector = {
    x = 1,
    y = 1
  }

  -- Transition for the selector colors (red and lighter red)
  self.selectorColors = {
    [1] = {255, 0, 0, 250},
    [2] = {255, 100, 100, 255}
  }

  -- The active selector that switches between the two colors.
  self.activeSelectorColor = 1
  Timer.every(0.5, function()
    
    -- Cycle the colors
    self.activeSelectorColor = self.activeSelectorColor % #self.selectorColors + 1
  end)


end

--[[
  Load the basic need from the params
]]
function PlayState:enter(params)

  -- The current level.
  self.level = params.level

  -- The current score. This is the only parameter that this state can manipulate.
  self.score = params.score

  -- The current goal.
  self.goal = params.goal

  -- The final / total score, accumulated score for all levels.
  self.finalScore = params.finalScore

  -- The timer.
  self.timer = params.timer

  Timer.every(1, function()
    -- Every 1 second, decrease the timer
    self.timer = self.timer - 1

    if self.timer <= 5 then
      -- Play the ticking sound if the timer is less than or equal to 5.
      gSounds['clock']:stop()
      gSounds['clock']:play()
    end
  end)

  self.board = params.board
end

--[[
  Update the game components
]]
function PlayState:update(dt)

  if self.gameOver then
    -- If the game is over, there is no sense updating this state.
    return
  end

  if self.timer <= 0 then
    -- The game is over.
    self.gameOver = true
    Timer.clear()
    gSounds['game-over']:play()

    Timer.tween(1, {
      [self] = {transitionAlpha = 255}
    }):finish(function()
      gStateMachine:change('summary', {
        level = self.level,
        score = self.score,
        timer = self.timer,
        finalScore = self.finalScore,
        
        -- Set the transition color to black.
        transitionColor = {r = 0, g = 0, b = 0},
        nextState = 'game-over'
      })
    end)
  end
  
  if not self.readInputs then
    -- The score to goal checking will not also happen while the board is clearing tiles.
    return
  end

  if self.score >= self.goal then
    Timer.clear()
    
    gSounds['next-level']:play()
    gStateMachine:change('summary', {
      level = self.level,
      score = self.score,
      timer = self.timer,
      finalScore = self.finalScore,

      -- Set the transition color to white.
      transitionColor = {r = 255, g = 255, b = 255},
      nextState = 'begin'
    })
  end

  -- Update the board
  self.board:update(dt)
  --[[
    Read the inputs from the user.
  ]]
  -- directional inputs
  if love.keyboard.wasPressed('left') or love.keyboard.wasPressed('a') then
    self.selector.x = self.selector.x - 1
    if self.selector.x <= 0 then
      self.selector.x = BOARD_WIDTH
    end
  elseif love.keyboard.wasPressed('right') or love.keyboard.wasPressed('d') then
    self.selector.x = self.selector.x + 1
    if self.selector.x > BOARD_WIDTH then
      self.selector.x = 1
    end
  end

  if love.keyboard.wasPressed('up') or love.keyboard.wasPressed('w') then
    self.selector.y = self.selector.y - 1
    if self.selector.y <= 0 then
      self.selector.y = BOARD_HEIGHT
    end
  elseif love.keyboard.wasPressed('down') or love.keyboard.wasPressed('s') then
    self.selector.y = self.selector.y + 1
    if self.selector.y > BOARD_HEIGHT then
      self.selector.y = 1
    end
  end

  -- selecton input
  if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then
    self:selectTiles()
  elseif love.mouse.wasPressed(1) then
    -- Calculate the coordinates if the button press is on the board.
    local coords = love.mouse.wasPressed(1)
    local boardX = coords.x - BOARD_X
    local boardY = coords.y - BOARD_Y

    local gridX = math.ceil(boardX / TILE_WIDTH)
    local gridY = math.ceil(boardY / TILE_HEIGHT)

    if gridX >= 0 and gridY >= 0 and gridX <= BOARD_WIDTH and gridY <= BOARD_HEIGHT then
      -- Only continue processing of the coordinates are on the board.
      self.selector.x = gridX
      self.selector.y = gridY
      self:selectTiles()
    end
  end

end

--[[
  Draw this current state.
]]
function PlayState:render()

  -- draw the stats at the side of the board.
  self:drawStats()
    
  -- render the board
  self.board:render()

  if self.hasHighlight then
    love.graphics.setColor(255, 255, 255, 150)
    self:drawBoardRectangle(self.highlighted, 'fill')
  end

  love.graphics.setColor(self.selectorColors[self.activeSelectorColor])
  love.graphics.setLineWidth(4)
  self:drawBoardRectangle(self.selector, 'line')

  love.graphics.setColor(0, 0, 0, self.transitionAlpha)
  love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

  resetColor()
end

--[[
  Display the stats of the game.
]]
function PlayState:drawStats()

  -- Set the background of the whole game.
  love.graphics.setColor(255, 255, 255, 100)
  love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

  -- show a darkened background for the stats themselves 
  love.graphics.setColor(0, 0, 0, 125)
  love.graphics.rectangle('fill', 32, 16, 160, 160)

  -- draw the level information.
  love.graphics.setFont(gFonts['large'])
  love.graphics.setColor(99, 155, 255, 255)

  love.graphics.printf('Level ' .. tostring(self.level), 32, 24, 160, 'center')

  love.graphics.setFont(gFonts['medium'])

  -- Draw the score
  love.graphics.printf('Score: ', 42, 72, 70, 'left')
  love.graphics.printf(tostring(self.score), 112, 72, 70, 'right')

  -- Draw the goal
  love.graphics.printf('Goal: ', 42, 112, 70, 'left')
  love.graphics.printf(tostring(self.goal), 112, 112, 70, 'right')

  -- Draw the timer
  love.graphics.printf('Timer: ', 42, 150, 70, 'left')
  love.graphics.printf(tostring(self.timer), 112, 150, 70, 'right')

end

--[[
  Draw a rectangle based on the given coordinates in a table.
]]
function PlayState:drawBoardRectangle(rect, mode)

  if rect == nil then
    return
  end

  love.graphics.rectangle(
    mode,
    (rect.x - 1) * TILE_WIDTH + BOARD_X,
    (rect.y - 1) * TILE_HEIGHT + BOARD_Y,
    TILE_WIDTH,
    TILE_HEIGHT,
    4
  )
end

-- Select/highlight a tile.
function PlayState:selectTiles()

  if not self.hasHighlight then
    -- Highlight the tile at the selectors position if there is no highlighted tile.
    self.hasHighlight = true
    self.highlighted = self.board.tiles[self.selector.y][self.selector.x]
    gSounds['select']:stop()
    gSounds['select']:play()
  else

    gSounds['select']:stop()
    gSounds['select']:play()

    -- retrieve the tiles to be swapped
    local current = self.board.tiles[self.selector.y][self.selector.x]
    local another = self.highlighted

    -- There are two selected tiles, attempt to swap.
    self:swapTiles(current, another)

    -- Regardless of what happens, the highlighted selection will be reset.
    self.hasHighlight = false
  end

end

--[[
  Attempt to swap the tiles
]]
function PlayState:swapTiles(current, another, reverting)

  self.readInputs = false
  local currentX, currentY = current.x, current.y -- Grid coordinates for the current tile
  local cDisplayX, cDisplayY = current.displayX, current.displayY -- display coordinates

  local anotherX, anotherY = another.x, another.y -- Grid coordinates for the highlighted tile
  local aDisplayX, aDisplayY = another.displayX, another.displayY -- display coordinates

  local tempTile = current

  if current:swap(another) then

    local tempX, tempY = currentX, currentY

    self.board.tiles[currentY][currentX] = another
    self.board.tiles[anotherY][anotherX] = current
    another.x, another.y = currentX, currentY
    current.x, current.y = anotherX, anotherY

    Timer.tween(0.2, {
      [current] = {displayX = aDisplayX, displayY = aDisplayY},
      [another] = {displayX = cDisplayX, displayY = cDisplayY}
    }):finish(function()
      if reverting then
        -- Enable the input reading, there will be no match calculation.
        self.readInputs = true
        return
      end

      -- Begin the calculation of the matches.
      self:calculateMatches(current, another)
    end)
  else
    self.readInputs = true
  end

end

--[[
  Attempt to match tiles, revert if there is no match.
]]
function PlayState:calculateMatches(current, another)

  self.readInputs = false
  if self.board:checkMatch() then

    for i, match in pairs(self.board.matches) do
      for j, tile in pairs(match) do
        self.timer = math.min(TIMER_LIMIT, self.timer + 1)
        self.score = self.score + (BASE_SCORE * tile.pattern)
      end
    end

    gSounds['match']:stop()
    gSounds['match']:play()

    -- Remove the matches.
    self.board:removeMatches()
    local fallingTiles = self.board:pullTilesDown()

    Timer.tween(0.25, fallingTiles):finish(function()
      Timer.tween(0.25, self.board:replenishTiles()):finish(function()
        self:calculateMatches()
      end)
    end)
  else
    
    self.readInputs = true
    if current == nil or another == nil then
      -- Don't do anything if the tiles required for reverting the swap are not found.
      return
    end

    gSounds['error']:stop()
    gSounds['error']:play()
    -- Revert the swap
    self:swapTiles(current, another, true)
  end

end