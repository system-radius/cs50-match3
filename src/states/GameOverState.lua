GameOverState = Class{__includes = BaseState}

--[[
  Initialize this state
]]
function GameOverState:init()
  self.transitionAlpha = 255

  Timer.tween(1, {
    [self] = {transitionAlpha = 0}
  })
end

--[[
  Only the final score is needed from the parameters.
]]
function GameOverState:enter(params)
  self.finalScore = params.finalScore
end

--[[
  For processing input.
]]
function GameOverState:update(dt)
  if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then
    -- Go back to the start screen
    gStateMachine:change('start')
  end
end

--[[
  Draw this state.
]]
function GameOverState:render()

  love.graphics.setColor(0, 0, 0, 150)
  love.graphics.rectangle('fill', 192, 64, 128, 160, 10)

  love.graphics.setColor(99, 155, 255, 255)
  
  love.graphics.setFont(gFonts['large'])
  love.graphics.printf('GAME', 0, 86, VIRTUAL_WIDTH, 'center')
  love.graphics.printf('OVER', 0, 114, VIRTUAL_WIDTH, 'center')

  love.graphics.setFont(gFonts['medium'])
  love.graphics.printf('Final Score:', 0, 162, VIRTUAL_WIDTH, 'center')
  love.graphics.printf(tostring(self.finalScore), 0, 176, VIRTUAL_WIDTH, 'center')

  love.graphics.setFont(gFonts['small'])
  love.graphics.printf('Press Enter to continue', 0, 206, VIRTUAL_WIDTH, 'center')

  love.graphics.setColor(0, 0, 0, self.transitionAlpha)
  love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

end