--[[

Copyright (c) 2016 by Marco Lizza (marco.lizza@gmail.com)

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgement in the product documentation would be
   appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.

]]--

-- MODULE INCLUSIONS -----------------------------------------------------------

local config = require('game.config')
local Entity = require('game.entities.entity')
local Animator = require('lib.animator')
local soop = require('lib.soop')

-- MODULE DECLARATION ----------------------------------------------------------

-- MODULE OBJECT CONSTRUCTOR ---------------------------------------------------

local Player = soop.class(Entity)

-- LOCAL CONSTANTS -------------------------------------------------------------

-- LOCAL FUNCTIONS -------------------------------------------------------------

-- MODULE FUNCTIONS ------------------------------------------------------------

function Player:initialize(parameters)
  local base = self:base()
  base.initialize(self, parameters)
  
  self.type = 'player'
  self.priority = 2
  self.radius = 8
  self.life = 1
  self.state = nil

  self.animator = Animator.new()
  self.animator:initialize(
      {
        defaults = {
          width = 16,
          height = 16,
          frequency = 6,
          on_loop = nil
        },
        animations = {
          ['running'] = { filename = 'assets/data/car.png' },
          ['running-night'] = { filename = 'assets/data/car-dark.png' }
        }
      })
  self.animator:switch_to('running')
end

function Player:update(dt)
  self.animator:update(dt)
end

function Player:change(state, age)
  -- If the age tells so, switch to dark.
  if age >= config.game.night_time then
    self.animator:switch_to('running-night', true) -- synch animations
  end
  
  -- Bail out if the state doesn't change. This is just an optimization, it
  -- wouldn't hurt, anyway.
  if self.state == state then
    return
  end
  self.state = state

  -- The avatar animation is stopped as long as the player input is not active.
  -- In this case, we keep the animation to the first frame.
  if state == 'moving' then
    self.animator:resume()
  else
    self.animator:pause()
  end
end

function Player:draw()
  -- Making sure not to colorize the sprite!
  love.graphics.setColor(255, 255, 255)
  
  local cx, cy = unpack(self.position)
  self.animator:draw(cx, cy)
end

-- END OF MODULE ---------------------------------------------------------------

return Player

-- END OF FILE -----------------------------------------------------------------
