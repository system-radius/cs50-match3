BeginState = Class{__includes = BaseState}

--[[
  Initialize the state.
]]
function BeginState:init()
  
  self.transitionAlpha = 255
  self.loadingAlpha = 255

  self.loading = false

  -- For tracking the label with the level text.
  self.levelY = -64

end

--[[
  Update the level. Entering the begin state should start with level 0.
]]
function BeginState:enter(params)

  -- Level up!
  self.level = params.level + 1 or 1
  self.finalScore = params.finalScore

  self.board = Board(self.level)
  
  -- Fade in from the last screen
  Timer.tween(1, {
    [self] = {transitionAlpha = 0}
  }):finish(function()
    
    -- After the fade, begin the level transition
    Timer.tween(0.25, {
      -- Place the level notifier at the middle Y
      [self] = {levelY = VIRTUAL_HEIGHT / 2 - 32}
    }):finish(function()
      
      -- Do not proceed while the board is not done loading.
      self.loading = true
      self:beginLoading()
      while not self.board.inplay do end
      self.loading = false
      
      -- After the level notifier reaches the middle
      -- count for N seconds then move notifier to the bottom.
      Timer.after(1, function()
        Timer.tween(0.25, {
          [self] = {levelY = VIRTUAL_HEIGHT}
        }):finish(function()
          -- After the level notifier is gone
          -- Change the state to play state
          gStateMachine:change('play', {
            level = self.level,
            board = self.board,
            -- Starting score for the level is alwaays 0
            score = 0,
            -- Keep track of the total score
            finalScore = self.finalScore,
            goal = self.level * BASE_GOAL,
            timer = TIMER_LIMIT
          })
        end)
      end)

    end)
    
  end)

end

function BeginState:update(dt)
  -- There is nothing to update, as this state is a transition state.
end

--[[
  Draw the current state.
]]
function BeginState:render()

  love.graphics.setColor(95, 205, 228, 200)
  love.graphics.rectangle('fill', 0, self.levelY, VIRTUAL_WIDTH, 64)

  resetColor()
  love.graphics.setFont(gFonts['large'])
  love.graphics.printf('Level ' .. tostring(self.level), 0, self.levelY + 16, VIRTUAL_WIDTH, 'center')
  
  love.graphics.setColor(255, 255, 255, self.transitionAlpha)
  love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

  if self.loading then
    love.graphics.setColor(95, 205, 228, self.loadingAlpha)
    love.graphics.setFont(gFonts['small'])

    love.graphics.printf('Loading...', 0, VIRTUAL_HEIGHT - 10, VIRTUAL_WIDTH, 'center')
  end

end

function BeginState:beginLoading()
  self:tweenLoadingAlpha()
  Timer.every(1, function ()
    self:tweenLoadingAlpha()
  end)
end

function BeginState:tweenLoadingAlpha()

  Timer.tween(0.25, {
    [self] = {loadingAlpha = 255}
  }):finish(function()
    Timer.after(0.5, function()
      Timer.tween(0.25, {
        [self] = {loadingAlpha = 0}
      })
    end)
  end)

end