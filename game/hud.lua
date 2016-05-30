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
local graphics = require('lib.graphics')
local utils = require('lib.utils')
local Tweener = require('lib.tweener')

-- MODULE DECLARATION ----------------------------------------------------------

local Hud = {
}

-- MODULE OBJECT CONSTRUCTOR ---------------------------------------------------

Hud.__index = Hud

function Hud.new()
  local self = setmetatable({}, Hud)
  return self
end

-- LOCAL CONSTANTS -------------------------------------------------------------

local TEXTS = require('assets.data.texts')

local AREA = {
  math.floor(constants.SCREEN_WIDTH / 8), -- left
  math.floor(constants.SCREEN_HEIGHT / 8), -- top
  math.floor(7 * constants.SCREEN_WIDTH / 8), -- right
  math.floor(3 * constants.SCREEN_HEIGHT / 4) -- bottom
}

-- LOCAL FUNCTIONS -------------------------------------------------------------

-- Scan the message content, line by line, and compute the minimum containing
-- rectangle (width and height).
local function measure(lines, face)
  local width, height = 0, 0
  for _, line in ipairs(lines) do
    local w, h = graphics.measure(line, face)
    width = math.max(width, w)
    height = height + h
  end
  return width, height
end

-- Randomize a location for the message to appear, given its [width] and
-- [height].
local function randomize(width, height)
  local left, top, right, bottom = unpack(AREA)
  local x = love.math.random(left, right - width)
  local y = love.math.random(top, bottom - height)
  return x, y
end

-- MODULE FUNCTIONS ------------------------------------------------------------

function Hud:initialize()
  self.tweener = Tweener.new()
  self.tweener:initialize()
  
  self:reset()
end

function Hud:reset()
  self.message = nil
  self.index = 0
  self.state = 'wait'
end

function Hud:update(dt)
  self.tweener:update(dt)

  -- We are using a FSM driven by the tweener. According to the current
  -- state we create a tweener that updates the message properties and,
  -- upon completion, creates switches to the next state.
  --
  -- Note that we need to use a "tweening" intermediate state, used
  -- during the tweening, or we end up creating multiple tweener instances.
  if self.state == 'fade-in' then
    -- A message is currently displayed, so just advance it's relative ticker.
    self.index = utils.forward(self.index, TEXTS)

    -- Pick the next message from the clump.
    local text = TEXTS[self.index]

    -- Compute the message size and pick a random screen position for it.
    local width, height = measure(text, 'silkscreen')
    local x, y = randomize(width, height)

    -- Create the message "object".
    self.message = {
      text = text,
      face = 'silkscreen',
      color = 'white',
      alpha = 0,
      position = { x, y },
      size = { width, height }
    }
  
    self.state = 'tweening'
    self.tweener:linear(config.messages.timeouts.fade, function(ratio)
          self.message.alpha = ratio
        end,
        function()
          self.state = 'idle'
        end)
  elseif self.state == 'idle' then
    self.state = 'tweening'
    self.tweener:linear(config.messages.timeouts.idle * #self.message.text, function(_)
        end,
        function()
          self.state = 'fade-out'
        end)
  elseif self.state == 'fade-out' then
    self.state = 'tweening'
    self.tweener:linear(config.messages.timeouts.fade, function(ratio)
          self.message.alpha = 1 - ratio
        end,
        function()
          self.message = nil
          self.state = 'wait'
        end)
  elseif self.state == 'wait' then
    self.state = 'tweening'
    self.tweener:linear(config.messages.timeouts.wait, function(_)
        end,
        function()
          if self.index < #TEXTS then
            self.state = 'fade-in'
          else
            self.state = 'finished'
          end
        end)
  end
end

function Hud:draw()
  graphics.text('[ PRESS SPACE TO MOVE ]',
    constants.SCREEN_RECT, 'silkscreen', 'white', 'center', 'bottom', 1)
  
  local message = self.message
  if not message then
    return
  end

  local x, y = unpack(message.position)
  local alpha = math.floor(message.alpha * 255)

  -- Scan the message content, line by line, and draw it!
  for _, line in ipairs(message.text) do
    local width, height = graphics.measure(line, 'silkscreen')
    graphics.text(line, { x, y, x + width, y + height },
        'silkscreen', 'white', 'left', 'top', 1, alpha)
    y = y + height
  end
end

-- END OF MODULE ---------------------------------------------------------------

return Hud

-- END OF FILE -----------------------------------------------------------------
