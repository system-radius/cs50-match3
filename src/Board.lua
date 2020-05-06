Board = Class{}

--[[
  Object creation.
]]
function Board:init(level)
  
  -- Generation will allow the patterns to appear after specific levels.
  self.patternBound = math.min(level, 6)
  
  -- To be used when applying clear patterns on the tiles, the 'switch-case' of Lua.
  self.patternFunctions = {
    [1] = function() end,
    [2] = self.clearCrossPattern,
    [3] = self.clearCirclePattern,
    [4] = self.clearSquarePattern,
    [5] = self.clearTrianglePattern,
    [6] = self.clearStarPattern
  }

  self.inplay = false

  -- Repeat the following until there are no matches on the board.
  repeat
    self.patternMatches = {}
    self.matches = {}
    self.tiles = {}

    for y = 1, BOARD_HEIGHT do

      table.insert(self.tiles, {})
      for x = 1, BOARD_WIDTH do
        table.insert(self.tiles[y], self:createTile(x, y))
      end
    end
  until not self:checkMatch()

  self.inplay = true
  -- reset the matches
  self.matches = {}
  

end

-- Update this object.
function Board:update(dt)

  for y = 1, #self.tiles do
    for x = 1, #self.tiles[y] do
      if not (self.tiles[y][x] == nil) then
        self.tiles[y][x]:update(dt)
      end
    end
  end

end

-- Render this object.
function Board:render()

  -- Darken the background of the board.
  love.graphics.setColor(0, 0, 0, 150)
  love.graphics.rectangle(
    'fill',
    BOARD_X - 2,
    BOARD_Y - 2,
    (BOARD_WIDTH * TILE_WIDTH) + 4,
    (BOARD_HEIGHT * TILE_HEIGHT) + 4,
    4
  )

  -- Reset the color before rendering the tiles.
  resetColor()

  for y = 1, #self.tiles do
    for x = 1, #self.tiles[y] do
      if not (self.tiles[y][x] == nil) then
        self.tiles[y][x]:render()
      end
    end
  end

end

-- Board-specific functions --

--[[
  Creates a tile at the provided x and y coordinate. The given x and y should be from 1 to BOARD_WIDTH
  and 1 to BOARD_HEIGHT respectively. The tile itself will make the necessary adjustments for the display.
]]
function Board:createTile(x, y)

  -- Retrieve the color for the tile.
  local row = math.random(#gFrames)

  -- Retrieve the pattern for the tile.
  local col = math.random(self.patternBound)

  -- Create the actual tile.
  return Tile(x, y, BOARD_X, BOARD_Y, row, col, math.random(25) == 1 and true or false)
end

--[[
  A utility function that may be used to check if there are matches for the board
]]
function Board:checkMatch()

  local match = {} -- Contains the current tiles that match each other.

  local currentColor = 0

  -- Check for the matches horizontally.
  for y = 1, BOARD_HEIGHT do

    -- Reset the color on row transition
    currentColor = 0
    for x = 1, BOARD_WIDTH do

      local tileColor = self.tiles[y][x].color

      if tileColor == currentColor then
        -- There is a match, insert to the current match table
        table.insert(match, self.tiles[y][x])
      else
        -- Reset the color to the current one that was found.
        currentColor = tileColor

        if #match >= MIN_MATCH then
          -- If the match size before changing colors is greater than 3,
          -- then that match is valid to be cleared.
          table.insert(self.matches, match)
        end

        -- Reset the match table.
        match = {}

        -- Then insert the current tile.
        table.insert(match, self.tiles[y][x])
      end

    end
  end

  if #match >= MIN_MATCH then
    -- Insert the match after the loop if there is, since this may not have been checked inside the loop.
    table.insert(self.matches, match)
  end

  -- Reset
  currentColor = 0
  match = {}

  -- Check for the matches vertically.
  for x = 1, BOARD_WIDTH do

    -- Reset the color on column transition
    currentColor = 0
    for y = 1, BOARD_HEIGHT do

      local tileColor = self.tiles[y][x].color

      if tileColor == currentColor then
        -- There is a match, insert to the current match table
        table.insert(match, self.tiles[y][x])
      else
        -- Reset the color to the current one that was found.
        currentColor = tileColor

        if #match >= MIN_MATCH then
          -- If the match size before changing colors is greater than 3,
          -- then that match is valid to be cleared.
          table.insert(self.matches, match)
        end

        -- Reset the match table.
        match = {}

        -- Then insert the current tile.
        table.insert(match, self.tiles[y][x])
      end

    end
  end

  if #match >= MIN_MATCH then
    -- Insert the match after the loop if there is, since this may not have been checked inside the loop.
    table.insert(self.matches, match)
  end

  -- Find pattern matches.
  self:matchPatterns()
  return #self.matches > 0
end

--[[
  Finds consecutive patterns on the tiles in the matches acquired via Board:checkMatch()
]]
function Board:matchPatterns()

  -- Clear the table of pattern matches.
  self.patternMatches = {}

  for i, match in pairs(self.matches) do

    -- Find the shiny tiles first.
    self:clearShiny(match)

    local patternMatch = {}

    local currentPattern = 0
    local patternCount = 0

    -- For each tile in the match, check if there are patterns that consecutively occurred.
    for j, tile in pairs(match) do

      if currentPattern == 0 or not (currentPattern == tile.pattern) then
        
        if patternCount >= MIN_MATCH then
          -- Apply the effect of the pattern.
          self.patternFunctions[currentPattern](self, patternMatch) 
        end
        
        if #match - (j - 1) < MIN_MATCH then
          -- End this current loop if there are no more pattern matches to be found.
          
          break
        end
        
        -- Reset / initialize the pattern counting values
        currentPattern = tile.pattern
        patternCount = 1
        patternMatch = {}
        table.insert(patternMatch, tile)
        
      elseif currentPattern == tile.pattern then
        -- Adjust the pattern count
        patternCount = patternCount + 1
        table.insert(patternMatch, tile)

      end

      
    end
    
    if patternCount >= MIN_MATCH then
      -- Post loop application of pattern match
      -- Apply the effect of the pattern.
      self.patternFunctions[currentPattern](self, patternMatch)
    end

  end

  -- After all of the matches were checked, add the retrieved pattern matches
  -- to the table of matches that will be cleared. This is so that the matches
  -- will not be disturbed with the new addition from the pattern match.
  for i, match in pairs(self.patternMatches) do
    table.insert(self.matches, match)
  end

end

--[[
  Check the if the current match has a shiny tile, then apply cirle pattern clear on that.
]]
function Board:clearShiny(match)

  local patternMatch = {}
  for i, tile in pairs(match) do
    if tile.shiny then
      tile.shiny = false
      table.insert(patternMatch, tile)

      -- Only retrieve one shiny tile from the match.
      break
    end
  end

  if #patternMatch > 0 then
    self:clearCirclePattern(patternMatch)
  end
end

--[[
  Delete the recorded matches from the board.
]]
function Board:removeMatches()

  for i, match in pairs(self.matches) do
    for j, tile in pairs(match) do
      self.tiles[tile.y][tile.x] = nil
    end
  end

  self.matches = {}

end

--[[
  Spaces will be left on the board after the delete is done. This function allows 'gravity'
  to pull the tiles so that the generated tiles will be on top.
]]
function Board:pullTilesDown()
  local tweens = {}

  local emptyX, emptyY = 0, 0
  local lowestEmtpyY = 0
  for x = 1, BOARD_WIDTH do
    
    -- reset the lowest empty Y 
    lowestEmtpyY = 0
    local y = BOARD_HEIGHT
    while y > 0 do

      local tile = self.tiles[y][x]
      if tile == nil and lowestEmtpyY == 0 then
        -- mark the lowest point in the current column that does not have a tile.
        lowestEmtpyY = y
        goto continueY
      elseif not (tile == nil) and lowestEmtpyY > 0 then
        -- If the marker has something, move the current tile to the position of the marker.
        tweens[tile] = {
          displayY = (lowestEmtpyY - 1) * TILE_HEIGHT + BOARD_Y
        }

        -- Move the tile
        tile.y = lowestEmtpyY

        self.tiles[lowestEmtpyY][x] = tile
        self.tiles[y][x] = nil

        -- Move the marker one space above.
        lowestEmtpyY = lowestEmtpyY - 1

        -- reset the y to the current empty space.
        y = lowestEmtpyY
      end

      ::continueY::
      y = y - 1
    end
  end

  return tweens
end

--[[
  Regenerate tiles. The lost tiles from clearing matches are to be replaced.
]]
function Board:replenishTiles()

  local tweens = {}
  for y = 1, BOARD_HEIGHT do
    for x = 1, BOARD_WIDTH do
      if self.tiles[y][x] == nil then
        -- Place a new tile here.
        local tile = self:createTile(x, y)
        local posY = (y - 1) * TILE_HEIGHT + BOARD_Y
        tile.displayY = 0 - TILE_HEIGHT

        self.tiles[y][x] = tile
        -- tile.displayY = posY
        tweens[tile] = {
          displayY = posY
        }
      end
    end
  end

  return tweens
end

--[[
  Behavior for clearing cross patterns. This will select plain tiles all over the board and clear them.
]]
function Board:clearCrossPattern(match)

  -- Get one tile from the match and assess the color.
  local color = match[1].color

  -- This is considered as one match only.
  local patternMatch = {}

  -- Retrieve all of the blocks in the board that has the same color.
  for y = 1, BOARD_HEIGHT do
    for x = 1, BOARD_WIDTH do
      local tile = self.tiles[y][x]

      -- Only retrieve the same colored tiles with same patterns.
      if tile.color == color and tile.pattern == 1 then
        table.insert(patternMatch, tile)
      end
    end
  end

  table.insert(self.patternMatches, patternMatch)

end

--[[
  Behavior for clearing circle patterns. This will clear the horizontal lines related to the current match.
  It is effectively used if the current match is vertical, this will cover more lines.
]]
function Board:clearCirclePattern(match)
  
  local patternMatch = {}
  local lastY = 0

  -- For each tile in the current match
  for i, tile in pairs(match) do
    local y = tile.y
    
    if y == lastY then
      -- Only do this if the tiles in the match are not on the same row.
      break
    end

    lastY = y

    -- Retrieve all of the tiles on the same row.
    for x = 1, BOARD_WIDTH do
      table.insert(patternMatch, self.tiles[y][x])
    end
  end

  table.insert(self.patternMatches, patternMatch)

end

--[[
  Behavior for clearing square patterns. This will clear the vertical lines related to the current match.
  It is effectively used if the current match is horizontal, this will cover more lines. 
]]
function Board:clearSquarePattern(match)

  local patternMatch = {}
  local lastX = 0

  -- For each tile in the current match
  for i, tile in pairs(match) do
    local x = tile.x
    
    if x == lastX then
      -- Only do this if the tiles are not on the same column.
      break
    end

    lastX = x

    -- Retrieve all of the tiles on the same column.
    for y = 1, BOARD_HEIGHT do
      table.insert(patternMatch, self.tiles[y][x])
    end
  end

  table.insert(self.patternMatches, patternMatch)

end

--[[
  Behavior for clearing triangle patterns. This combines the behavior of circle and square pattern clears.
]]
function Board:clearTrianglePattern(match)

  self:clearCirclePattern(match)
  self:clearSquarePattern(match)

end

--[[
  Behavior for clearing star patterns. This combines the behavior of triangle and cross pattern clear.
]]
function Board:clearStarPattern(match)

  self:clearCrossPattern(match)
  self:clearTrianglePattern(match)

end