Tile = Class{}

-- Used for the particle system to generate shiny indicator.
local lifetime = 1
local particles = 2

function Tile:init(x, y, offsetX, offsetY, color, pattern, shiny)

  self.x = x
  self.y = y

  -- The display coordinates, transformed from the grid coordinates.
  self.displayX = (x - 1) * TILE_WIDTH + offsetX
  self.displayY = (y - 1) * TILE_HEIGHT + offsetY

  self.color = color
  self.pattern = pattern

  self.shiny = shiny

  if self.shiny then
    -- Create shiny particles for the tile.

    self.psystemAlpha = 0
    self:shine()
    Timer.every(1, function()
      self:shine()
    end)

    self.psystems = {}

    local string = ''
    local limit = 2
    for i = 1, limit do
      local psystem = love.graphics.newParticleSystem(gTextures['sp'], 64)

      psystem:setParticleLifetime(lifetime, lifetime)
      psystem:setLinearAcceleration(-10, -10, 10, 10)
      psystem:setAreaSpread('uniform', 4, 4)

      table.insert(self.psystems, psystem)

    end

    self:createShinyParticles(1, limit)
  end

end

function Tile:update(dt)

  if self.shiny then
    for i, psystem in pairs(self.psystems) do
      psystem:update(dt)
    end
  end

end

function Tile:render()

  resetColor()
  love.graphics.draw(gTextures['tiles'], gFrames[self.color][self.pattern],
    self.displayX,
    self.displayY
  )

  if self.shiny then
    love.graphics.setColor(255, 255, 255, self.psystemAlpha)
    love.graphics.rectangle('fill', self.displayX, self.displayY, TILE_WIDTH, TILE_HEIGHT, 10)

    love.graphics.setColor(255, 255, 255, 200)
    for i, psystem in pairs(self.psystems) do
      love.graphics.draw(psystem, self.displayX + TILE_WIDTH - TILE_WIDTH / 2, self.displayY + TILE_HEIGHT - TILE_HEIGHT / 2)
    end
  end
end

function Tile:swap(other)

  return not (math.abs(other.x - self.x) + math.abs(other.y - self.y) > 1)
end

function Tile:shine()

  -- self.psystem:emit(4)
  Timer.tween(0.5, {
    [self] = {psystemAlpha = 100}
  }):finish(function()
    Timer.tween(0.5, {
      [self] = {psystemAlpha = 0}
    })
  end)
end

function Tile:createShinyParticles(i, limit)

  if i > limit then
    return
  end

  self.psystems[i]:emit(particles)
  Timer.after(0.5, function()
    -- Every 0.5 seconds, allow a system to emit.
    Timer.every(lifetime, function()
      self.psystems[i]:emit(particles)
    end)

    self:createShinyParticles(i + 1, limit)
  end)

end