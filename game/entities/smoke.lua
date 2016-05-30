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

local Entity = require('game.entities.entity')
local graphics = require('lib.graphics')
local easing = require('lib.easing')
local soop = require('lib.soop')

-- MODULE DECLARATION ----------------------------------------------------------

-- MODULE OBJECT CONSTRUCTOR ---------------------------------------------------

local Smoke = soop.class(Entity)

-- LOCAL CONSTANTS -------------------------------------------------------------

-- LOCAL FUNCTIONS -------------------------------------------------------------

-- MODULE FUNCTIONS ------------------------------------------------------------

function Smoke:initialize(parameters)
  local base = self:base()
  base.initialize(self, parameters)

  self.type = 'smoke'
  self.priority = 1
  self.ephemeral = true
  self.origin = { unpack(parameters.position) }
  self.radius = parameters.radius
  self.speed = parameters.speed
  self.life = parameters.life
  self.reference = parameters.life
  self.color = parameters.color
  self.rotation = parameters.rotation
  self.spin = parameters.spin
end

function Smoke:update(dt)
  -- Decrease the current life. If "dead" bail out.
  if self.life > 0 then
    self.life = self.life - dt
  end
  if self.life <= 0 then
    self.life = 0
    return
  end
  
  local alpha = self.life / self.reference
  local inv_alpha = 1 - alpha

  -- Update the particle rotation.
  self.rotation = self.rotation + self.spin * dt
  
  -- Compute the current entity velocity and update its position.
  local x, y = unpack(self.origin)
  local sx, sy = math.cos(self.angle) * self.speed, math.sin(self.angle) * self.speed
  self.position = { x + easing.linear(inv_alpha) * sx, y + easing.cubic(inv_alpha) * sy }
  
--  self.position = { self:cast(self.speed * dt) }
end

function Smoke:draw()
  if self.life <= 0 then
    return
  end
  
  local x, y = unpack(self.position)
  local alpha = self.life / self.reference
  
  -- The particle radius is dinamically calculated. It become bigger as the
  -- time progresses.
  local radius  = self.radius * (1 - easing.cubic(alpha))
  local half_radius = radius / 2

  local cx, cy = x + half_radius, y + half_radius
 
  love.graphics.push()
  love.graphics.translate(cx, cy)
  love.graphics.rotate(self.rotation)
  love.graphics.translate(-cx, -cy)
  graphics.square(x, y, radius, self.color, easing.hill(alpha) * 255)
  love.graphics.pop()
end

-- END OF MODULE ---------------------------------------------------------------

return Smoke

-- END OF FILE -----------------------------------------------------------------
