SummaryState = Class{__includes = BaseState}

--[[
  Transition function from another state.
]]
function SummaryState:enter(params)
  self.score = params.score
  self.level = params.level
  self.timer = params.timer

  self.finalScore = params.finalScore

  -- Params related to transitions
  self.transitionColor = params.transitionColor
  self.nextState = params.nextState

  -- For the purposes of tweening
  self.displayFinal = self.finalScore
  self.displayScore = self.score
  self.displayTimer = self.timer

  -- Begin the transitions
  self.transitionAlpha = 255

  self.summaryComplete = false
  self.nextTransition = 0

  self.readInputs = false

  -- Fade in
  Timer.tween(1, {
    [self] = {transitionAlpha = 0}
  }):finish(function() 

    self.readInputs = true
    -- Pause for 0.5 seconds
    Timer.after(0.5, function()

      -- After the first transition, show the scores being accumulated.
      local newScore = self.displayFinal + self.displayScore
      Timer.tween(1, {
        [self] = {
          displayFinal = newScore,
          displayScore = 0
        }
      }):finish(function()

        -- Introduce a pause for the calculations
        Timer.after(0.5, function()

          -- Then resume with the inclusion of the timer scores
          local timerScore = self.displayFinal + (self.displayTimer * (BASE_SCORE / 2))    
          Timer.tween(1, {
            [self] = {
              displayFinal = timerScore,
              displayTimer = 0
            }
          }):finish(function()

            -- The summary is complete
            self:complete()

          end)
        end)
      end)
    end)
  end)

end

--[[
  Update the current state
]]
function SummaryState:update(dt)

  if not self.readInputs then
    return
  end

  if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then

    if self.summaryComplete then
      -- If the summary is done displaying the final stats, proceed to the next state.
      -- Fade out
      Timer.tween(1, {
        [self] = {transitionAlpha = 255}
      }):finish(function()
        gStateMachine:change(self.nextState, {
          finalScore = self.finalScore,
          level = self.level
        })
      end)
    else
      -- Otherwise, force the summary to complete itself.

      -- Clear the timer to stop the existing transitions
      Timer.clear()
  
      -- Instantly set the stats
      self.displayFinal = self.finalScore + self.score + (self.timer * (BASE_SCORE / 2))
      self.displayScore = 0
      self.displayTimer = 0
  
      self:complete()
    end

  end

end

--[[
  Render the current state
]]
function SummaryState:render()

  love.graphics.setColor(0, 0, 0, 150)
  love.graphics.rectangle('fill', 160, 64, 192, 160, 10)

  love.graphics.setColor(99, 155, 255, 255)
  
  love.graphics.setFont(gFonts['large'])
  love.graphics.printf('Level ' .. tostring(self.level), 0, 70, VIRTUAL_WIDTH, 'center')

  love.graphics.setFont(gFonts['medium'])

  -- Render the total / final score
  love.graphics.printf('Total Score:', 0, 115, VIRTUAL_WIDTH, 'center')
  love.graphics.printf(tostring(self.displayFinal - (self.displayFinal % 1)), 0, 128, VIRTUAL_WIDTH, 'center')

  -- Render the score from the current level
  love.graphics.printf('Score:', 168, 160, 88, 'left')
  love.graphics.printf(tostring(self.displayScore - (self.displayScore % 1)), 256, 160, 88, 'right')

  -- Render the remaining time
  love.graphics.printf('Time:', 168, 192, 88, 'left')
  love.graphics.printf(tostring(self.displayTimer - (self.displayTimer % 1)), 256, 192, 88, 'right')

  if self.summaryComplete then
    -- Render the transition prompt if the summary is complete.
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(99, 155, 255, self.nextTransition)
    love.graphics.printf('Press Enter to continue', 0, 214, VIRTUAL_WIDTH, 'center') 
  end

  -- Transition rectangle
  love.graphics.setColor(self.transitionColor.r, self.transitionColor.g, self.transitionColor.b, self.transitionAlpha)
  love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

end

--[[
  Tweens the transparency of the transition prompt, giving the fade in and fade out effect.
]]
function SummaryState:tweenTransitionPrompt()
  
  -- Allow the prompt to fade in
  Timer.tween(0.5, {
    [self] = {nextTransition = 255}
  }):finish(function()

    -- Wait for a second
    Timer.after(1, function()

      -- Then fade out
      Timer.tween(0.5, {
        [self] = {nextTransition = 0}
      })
    end)
  end)

end

--[[
  To be called to begin displaying the transition prompt 'Press Enter to continue.'
  The prompt fades in and out every 2 seconds.
]]
function SummaryState:displayTransitionPrompt()

  -- Do this right away.
  self:tweenTransitionPrompt()

  Timer.every(2, function()
    self:tweenTransitionPrompt()
  end)
end

function SummaryState:complete()

  self.summaryComplete = true
  self.finalScore = self.finalScore + self.score + (self.timer * (BASE_SCORE / 2))
  self:displayTransitionPrompt()

end