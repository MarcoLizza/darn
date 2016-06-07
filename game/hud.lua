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

-- LOCAL FUNCTIONS -------------------------------------------------------------

-- MODULE FUNCTIONS ------------------------------------------------------------

function Hud:initialize()
  self.tweener = Tweener.new()
  self.tweener:initialize()
  
  self:reset()
end

function Hud:reset()
end

function Hud:update(dt)
  self.tweener:update(dt)
end

function Hud:draw()
end

-- END OF MODULE ---------------------------------------------------------------

return Hud

-- END OF FILE -----------------------------------------------------------------
