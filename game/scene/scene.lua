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

local Layer = require('game.scene.layer')

-- MODULE DECLARATION ----------------------------------------------------------

local Scene = {
}

-- MODULE OBJECT CONSTRUCTOR ---------------------------------------------------

Scene.__index = Scene

function Scene.new()
  local self = setmetatable({}, Scene)
  return self
end

-- LOCAL CONSTANTS -------------------------------------------------------------

-- LOCAL FUNCTIONS -------------------------------------------------------------

-- MODULE FUNCTIONS ------------------------------------------------------------

function Scene:initialize(age, on_draw)
  self.layers = {}
  self.age = age
  self.alpha = 1
  self.on_draw = on_draw
end

function Scene:reset()
  self.layers = {}
end

function Scene:push(params)
  local layer = Layer.new()
  layer:initialize(params)

  table.insert(self.layers, layer)
  table.sort(self.layers, function(a, b)
        return a.depth > b.depth
      end)
end

function Scene:scroll(direction)
  for _, layer in ipairs(self.layers) do
    layer:scroll(direction)
  end
end

function Scene:update(dt)
  for _, layer in ipairs(self.layers) do
    layer:update(dt)
  end
end

function Scene:draw()
  for _, layer in ipairs(self.layers) do
    layer:draw(self.alpha)
  end

  if self.on_draw then
    self.on_draw()
  end
end

-- END OF MODULE ---------------------------------------------------------------

return Scene

-- END OF FILE -----------------------------------------------------------------
