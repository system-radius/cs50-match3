StartState = Class{__includes = BaseState}

-- Contains the letters and their respective X-coordinate
local letters = {
  {'M', 192},
  {'A', 216},
  {'T', 236},
  {'C', 252},
  {'H', 268},
  {'3', 304}
}

-- The Y-coordinate for rendering of the letters.
local lettersY = 103

-- The board offset, used to display tiles at the center.
local BOARD_OFFSET_X = (VIRTUAL_WIDTH / 2) - (BOARD_WIDTH / 2 * TILE_WIDTH)
local BOARD_OFFSET_Y = (VIRTUAL_HEIGHT / 2) - (BOARD_HEIGHT / 2 * TILE_HEIGHT)

-- Initialize the current state.
function StartState:init()

  self.highlight = 1
  self.transitionAlpha = 0

  -- Load the colors for giving the letters their different colors.
  self.colors = {
    -- Red
    [1] = {172, 50, 50, 255},
  
    -- Orange
    [2] = {223, 113, 38, 255},
  
    -- Yellow
    [3] = {217, 160, 102, 255},
  
    -- Green
    [4] = {55, 148, 110, 255},
  
    -- Blue
    [5] = {91, 110, 225, 255},
  
    -- Gray
    [6] = {132, 126, 135, 255},
  
    -- Violet
    [7] = {118, 66, 138, 255}
  
  }

  -- The colors for the options, highlighted and default.
  self.defaultColors = {
    [1] = {99, 155, 255, 255},
    [2] = {48, 96, 130, 255}
  }

  -- Start the color shifting.
  Timer.every(0.075, function()
    
    local finalColor = self.colors[#self.colors]

    for i = #self.colors, 2, -1 do
      self.colors[i] = self.colors[i - 1]
    end

    self.colors[1] = finalColor

  end)

  -- Initialize the display tiles.
  self.tiles = {}
  for y = 1, BOARD_HEIGHT do
    table.insert(self.tiles, {})
    for x = 1, BOARD_WIDTH do
      local color = math.random(#gFrames)
      local pattern = math.random(#gFrames[color])
      table.insert(self.tiles[y], Tile(x, y, BOARD_OFFSET_X, BOARD_OFFSET_Y, color, pattern))
    end
  end

end

--[[
  Mainly reading the inputs.
]]
function StartState:update(dt)

  if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return')  then
    self:selectOption()
  elseif love.keyboard.wasPressed('up') or love.keyboard.wasPressed('down') then
    self.highlight = self.highlight % 2 + 1
  elseif love.keyboard.wasPressed('escape') then
    love.event.quit()
  end

  if love.mouse.wasPressed(1) then
    self:selectOption()
  end
  
  local x, y = push:toGame(love.mouse.getPosition())
  if x >= 234 and y >= 188 and x <= 282 and y <= 202 then
    self.highlight = 1
  elseif x >= 216 and y >= 214 and x <= 300 and y <= 228 then
    self.highlight = 2
  end
end

--[[
  Render the current state.
]]
function StartState:render()

  -- Draw the tiles.
  self:renderTiles()

  love.graphics.setColor(0, 0, 0, 150)
  love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

  love.graphics.setColor(255, 255, 255, 75)
  love.graphics.rectangle('fill', 160, 88, 192, 64, 10)
  love.graphics.setFont(gFonts['large'])
  for i = 1, #letters do

    self:drawWithShadow(self.colors[i], 2, letters[i][1], letters[i][2], lettersY)
    -- love.graphics.setColor(self.colors[i])
    -- love.graphics.print(letters[i][1], letters[i][2], lettersY)
  end

  love.graphics.setFont(gFonts['medium'])
  love.graphics.setColor(255, 255, 255, 75)
  love.graphics.rectangle('fill', 192, 176, 128, 64, 10)

  local currentColor = 2
  if self.highlight == 1 then
    currentColor = 1
  else
    currentColor = 2
  end
  self:drawWithShadow(self.defaultColors[currentColor], 1, 'Start', 0, 187, VIRTUAL_WIDTH, 'center')
  
  if self.highlight == 2 then
    currentColor = 1
  else
    currentColor = 2
  end
  self:drawWithShadow(self.defaultColors[currentColor], 1, 'Quit Game', 0, 214, VIRTUAL_WIDTH, 'center')

  love.graphics.setColor(255, 255, 255, self.transitionAlpha)
  love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

end

--[[
  Iterate over the tiles to draw them. Each tile has its own way of rendering itself.
]]
function StartState:renderTiles()

  for y = 1, BOARD_HEIGHT do
    for x = 1, BOARD_WIDTH do
      self.tiles[y][x]:render()
    end
  end

end

--[[
  For drawing texts with shadow.
]]
function StartState:drawWithShadow(color, gap, string, x, y, limit, align)

  love.graphics.setColor(0, 0, 0, 200)
  if limit == nil and align == nil then

    love.graphics.print(string, x + gap, y + gap)
    love.graphics.setColor(color)
    love.graphics.print(string, x, y)
  else

    love.graphics.printf(string, x + gap, y + gap, limit, align)
    love.graphics.setColor(color)
    love.graphics.printf(string, x, y, limit, align)
  end

end

--[[
  Selection of option.
]]
function StartState:selectOption()

  if self.highlight == 1 then
    -- Change the state to the begin level state.
    Timer.tween(1, {
      [self] = {transitionAlpha = 255}
    }):finish(function()
      gStateMachine:change('begin', {
        level = 0,
        finalScore = 0
      })
    end)
  else
    love.event.quit()
  end

end