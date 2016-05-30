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
local Player = require('game.entities.player')
local Smoke = require('game.entities.smoke')
local constants = require('game.constants')
local Entities = require('game.entities')
local Hud = require('game.hud')
local Scene = require('game.scene.scene')
local Tweener = require('lib.tweener')
local Timer = require('lib.timer')
local graphics = require('lib.graphics')
local utils = require('lib.utils')

-- MODULE DECLARATION ----------------------------------------------------------

local world = {
}

-- LOCAL CONSTANTS -------------------------------------------------------------

local SCENE = require('assets.data.scene')

-- LOCAL FUNCTIONS -------------------------------------------------------------

local function offset(position, dx, dy)
  local x, y = unpack(position)
  return x + dx, y + dy
end

-- MODULE FUNCTIONS ------------------------------------------------------------

function world:initialize()
  self.tweener = Tweener.new()
  self.tweener:initialize()

  self.entities = Entities.new()
  self.entities:initialize()

  self.hud = Hud.new()
  self.hud:initialize()
end

function world:reset()
  -- Reload all the scene
  self.scenes = {}
  for _, params in ipairs(SCENE) do
    local scene = Scene.new()
    scene:initialize(params.age, params.on_draw)
    for _, layer in ipairs(params.layers) do
      scene:push(layer)
    end
    self.scenes[#self.scenes + 1] = scene
  end
  
  -- Reset the world "age" to zero. Also, pick the first scene as the current
  -- one and clear the "next" scene reference (will be detected automatically
  -- depending on the age)
  self.state = 'normal'
  self.age = 0
  self.current = self.scenes[1]
  self.next = nil
  self.delta = 0

  -- Reset the entity manager and add the the player one at the center of the
  -- screen.
  self.entities:reset()
  self.player = Player.new()
  self.player:initialize({
        position = { constants.SCREEN_WIDTH / 2, constants.SCREEN_HEIGHT - 56},
        angle = 0
      })
  self.entities:push(self.player)
  
  -- Initialize an "emitter" timer that will pop the smoke periodically.
  self.emitter = Timer.create(0.5, function()
        local smoke = Smoke.new()
        smoke:initialize({
              position = { offset(self.player.position, 0, 13) },
              angle = utils.to_radians(180 + love.math.random() * 30 + 15),
              radius = love.math.random() * 4 + 2,
              speed = love.math.random() * 8 + 24,
              life = love.math.random() * 3 + 2,
              color = 'white',
              rotation = love.math.random() * math.pi,
              spin = love.math.random() * math.pi + math.pi
            })
        self.entities:push(smoke)
      end)
  
  -- Reset the HUD state, too.
  self.hud:reset()
end

function world:input(keys, dt)
  -- We just keep track of the user input as a "delta" value.
  self.delta = 0
  
  if not keys then
    return
  end
  
  if keys.pressed['space'] then
    self.delta = 1
  end
end

function world:update(dt)
  -- We compute a "scaled" delta-time, in order not to move/update if
  -- the user is not interacting. The nice thing is that by changing the
  -- scaling value we can also control the speed of the game.
  local sdt = self.delta * dt

  self.tweener:update(sdt)

  if not self.next then
    -- Compute the next age according to the player input. It is more like a
    -- "distance".
    self.age = self.age + sdt

    -- If the world is old enough, finish it... :)
    if self.state == 'normal' and self.age >= config.game.duration then
      self.state = 'finishing'
    end

    -- Find the scene to which the current age/distance belongs to.
    local next = nil
    for _, scene in ipairs(self.scenes) do
      if scene.age > self.age then
        break
      end
      next = scene
    end
    
    -- If the current scene is different from the one we are moving to, create
    -- a linear tweener to fade to the next one.
    if self.current ~= next then
      next.alpha = 0 -- HACK!!!

      self.next = next -- halt pogression during fading
      
      self.tweener:linear(config.game.timeouts.scene,
          function(ratio) -- on_update, make the next scene appear
            self.next.alpha = ratio
          end,
          function() -- on_complete, the next scene becomes the current one
            self.current = self.next
            self.next = nil
          end)
    end
  end

  -- Reverse the scroll direction to simulate movement
  local direction = 'none'
  if self.delta > 0 then
    direction = 'left'
  end

  self.current:scroll(direction)
  if self.next then
    self.next:scroll(direction)
  end

  self.current:update(sdt)
  if self.next then
    self.next:update(sdt)
  end

  -- Update the player state, according to current movement direction.
  self.player:change(direction == 'none' and 'still' or 'moving', self.age)

  -- We also update the emitters that (ehm) emits the smoke.
  self.emitter(sdt)

  -- The HUD, that displays the texts, is updated only according to user input.
  self.hud:update(sdt)

  -- The entities animations are updated with the plain time
  -- delta (unscaled) since we want them to animate also when the user is not
  -- interacting.
  self.entities:update(dt)
end

function world:draw()
  self.current:draw()
  if self.next then
    self.next:draw()
  end

  self.entities:draw()
  self.hud:draw()
--  graphics.text(string.format('AGE: %d', self.age),
--      constants.SCREEN_RECT, 'silkscreen', 'gray', 'right', 'top', 1)
end

-- END OF MODULE -------------------------------------------------------------

return world

-- END OF FILE ---------------------------------------------------------------
