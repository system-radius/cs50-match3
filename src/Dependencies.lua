-- library requirements
push = require "lib/push"
Class = require "lib/class"
Timer = require "lib/knife/Timer"

--[[
  source requirements
]]

require 'src/constants'
require 'src/StateMachine'

require 'src/Tile'
require 'src/Board'

require 'src/Utils'

-- Parent class for all of the states to be implemented.
require 'src/states/BaseState'
require 'src/states/StartState'
require 'src/states/BeginState'
require 'src/states/PlayState'
require 'src/states/SummaryState'
require 'src/states/GameOverState'