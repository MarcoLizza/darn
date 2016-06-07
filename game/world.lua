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
local constants = require('game.constants')
local Animated = require('game.entities.animated')
local Static = require('game.entities.static')
local Hud = require('game.hud')

local Entities = require('lib.entities')
local Shaker = require('lib.shaker')
local Tweener = require('lib.tweener')

-- MODULE DECLARATION ----------------------------------------------------------

local world = {
}

-- LOCAL CONSTANTS -------------------------------------------------------------

-- LOCAL FUNCTIONS -------------------------------------------------------------

-- MODULE FUNCTIONS ------------------------------------------------------------

function world:initialize()
  self.entities = Entities.new()
  self.entities:initialize(function(a, b) -- lower priority => earlier drawn
        return a.priority < b.priority
      end)

  self.shaker = Shaker.new()
  self.shaker:initialize()
  
  self.tweener = Tweener.new()
  self.tweener:initialize()

  self.hud = Hud.new()
  self.hud:initialize()
end

function world:reset()
  -- Reset the world "age" to zero. Also, pick the first scene as the current
  -- one and clear the "next" scene reference (will be detected automatically
  -- depending on the age)
  self.state = 'normal'
  self.age = 0
  self.can_interact = true
  self.interact = false

  -- Reset the entity manager and add the the player one at the center of the
  -- screen.
  self.entities:reset()
  
  local background = Static.new()
  background:initialize({
        id = 'background',
        position = { 0, 0 },
        angle = 0,
        life = math.huge,
        image = 'assets/data/background.png',
      })
  self.entities:push(background)

  local screen = Animated.new()
  screen:initialize({
        id = 'screen',
        position = { 0, 0 },
        angle = 0,
        life = math.huge,
        animations = {
          width = 480,
          height = 300,
          frequency = 4, -- 250ms per frame
          on_loop = nil,
          sequences = {
            ['static'] = 'assets/data/static.png',
            ['channel'] = 'assets/data/channel.png'
          }
        }
      })
  self.entities:push(screen)

  local television = Static.new()
  television:initialize({
        id = 'television',
        position = { 0, 0 },
        angle = 0,
        life = math.huge,
        image = 'assets/data/television.png'
      })
  self.entities:push(television)

  -- Reset the camera shaker to default state.
  self.shaker:reset()

  -- Reset the HUD state, too.
  self.hud:reset()
end

function world:input(keys, dt)
  -- If the player interact with the scene, keep track of it!
  self.interact = keys and keys.pressed['space']
end

function world:update(dt)
  if self.interact and self.can_interact then
  end

  self.entities:update(dt)
  self.shaker:update(dt)
  self.tweener:update(dt)

  self.hud:update(dt)
end

function world:draw()
  self.shaker:pre()
    self.entities:draw()
  self.shaker:post()
  
  self.hud:draw()
end

-- END OF MODULE -------------------------------------------------------------

return world

-- END OF FILE ---------------------------------------------------------------
