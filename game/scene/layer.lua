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

local graphics = require('lib.graphics')

-- MODULE DECLARATION ----------------------------------------------------------

local Layer = {
}

-- MODULE OBJECT CONSTRUCTOR ---------------------------------------------------

Layer.__index = Layer

function Layer.new()
  local self = setmetatable({}, Layer)
  return self
end

-- LOCAL CONSTANTS -------------------------------------------------------------

-- LOCAL FUNCTIONS -------------------------------------------------------------

-- MODULE FUNCTIONS ------------------------------------------------------------

function Layer:initialize(params)
  self.depth = params.depth
  self.position = { unpack(params.position) }
  self.offset = params.offset or 0
  self.speed = params.speed or 0
  self.image = love.graphics.newImage(params.file)
  self.alpha = params.alpha -- can be nil, won't fade at all
end

function Layer:scroll(direction)
  self.direction = direction
end

function Layer:update(dt)
  local sign = 0
  if self.direction == 'left' then
    sign = -1
  elseif self.direction == 'right' then
    sign = 1
  end
  self.offset = self.offset + self.speed * sign * dt
end

function Layer:draw(alpha)
  local image = self.image
  local width = image:getWidth()
  local height = image:getHeight()

  local x, y = unpack(self.position)
  x = (x + math.floor(self.offset)) % width

  local asx, atx, aw, bsx, btx, bw

  if x < 0 then
    --      +--------+
    -- +----+--+     |
    -- |    |  |     |
    -- +----+--+     |
    --      +--------+
    aw = width + x
    asx = -x
    atx = 0
    bw = -x
    bsx = 0
    btx = aw
  else
    --      +--------+
    --      |     +--+----+
    --      |     |  |    |
    --      |     +--+----+
    --      +--------+
    aw = x
    asx = width - x
    atx = 0
    bw = width - x
    bsx = 0
    btx = x
  end

  alpha = self.alpha and alpha * self.alpha or 1
  local a = math.floor(255 * alpha)

  graphics.image(self.image, atx, y, asx, 0, aw, height, a)
  graphics.image(self.image, btx, y, bsx, 0, bw, height, a)
end

-- END OF MODULE ---------------------------------------------------------------

return Layer

-- END OF FILE -----------------------------------------------------------------
