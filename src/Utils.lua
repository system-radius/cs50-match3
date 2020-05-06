
--[[
  Generic quad generation
]]
function GenerateQuads(atlas, tileWidth, tileHeight)
  local sheetWidth = atlas:getWidth() / tileWidth
  local sheetHeight = atlas:getHeight() / tileHeight

  local sheetCounter = 1
  local spritesheet = {}

  for y = 0, sheetHeight - 1 do
    for x = 0, sheetWidth - 1 do
      spritesheet[sheetCounter] = 
        love.graphics.newQuad(x * tileWidth, y * tileHeight,
          tileWidth, tileHeight, atlas:getDimensions())
      sheetCounter = sheetCounter + 1
    end
  end

  return spritesheet
end

--[[
  Generates a row of quads, depending on the given startY
]]
function GenerateRowQuads(atlas, tileWidth, tileHeight, startX, startY, limit)

  local counter = 1
  local spritesheet = {}

  local y = startY * tileHeight

  for x = startX, limit + startX do
    spritesheet[counter] = love.graphics.newQuad(
      x * tileWidth,
      y,
      tileWidth,
      tileHeight,
      atlas:getDimensions())
    counter = counter + 1
  end

  return spritesheet
end