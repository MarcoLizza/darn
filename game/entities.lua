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

-- MODULE DECLARATION ----------------------------------------------------------

local Entities = {
}

-- MODULE OBJECT CONSTRUCTOR ---------------------------------------------------

Entities.__index = Entities

function Entities.new()
  local self = setmetatable({}, Entities)
  return self
end

-- LOCAL FUNCTIONS -------------------------------------------------------------

-- MODULE FUNCTIONS ------------------------------------------------------------

function Entities:initialize(world)
  self:reset()
end

function Entities:reset()
  self.active = {}
  self.incoming = {}
end

function Entities:update(dt)
  -- If there are any waiting recently added entities, we merge them in the
  -- active entities list. The active list is kept sorted by entity
  -- priority.
  if #self.incoming > 0 then
    for _, entity in ipairs(self.incoming) do
      table.insert(self.active, entity);
    end
    self.incoming = {}
    table.sort(self.active, function(a, b)
          return a.priority < b.priority
        end)
  end
  -- Update and keep track of the entities that need to be removed.
  --
  -- Since we need to keep the entities list sorted, we remove "dead"
  -- entities from the back to front. To achive this we "push" the
  -- indices at the front of the to-be-removed list. That way, when
  -- we traverse it we can safely remove the elements as we go.
  local zombies = {}
  for index, entity in ipairs(self.active) do
    entity:update(dt)
    if not entity:is_alive() then
      table.insert(zombies, 1, index);
    end
  end
  for _, index in ipairs(zombies) do
    table.remove(self.active, index)
  end
end

function Entities:draw()
  for _, entity in pairs(self.active) do
    entity:draw()
  end
end

function Entities:push(entity)
  -- We store thre entity-manager reference in the entity itself. Could be
  -- useful.
  entity.entities = self

  -- We enqueue the added entries in a temporary list. Then, in the "update"
  -- function we merge the entries with the active entries list and sort it.
  -- 
  -- The rationale for this is to decouple the entities scan/iteration and
  -- the addition. For example, it could happen that during an iteration we
  -- add new entities; however we cannot modify the active entities list
  -- content while we iterate.
  --
  -- We are using the "table" namespace functions since we are continously
  -- scambling the content by reordering it.
  table.insert(self.incoming, entity)

end

function Entities:colliding()
  local colliding = {}
  -- Naive O(n^2) collision resulution algorithm.
  -- (with not projection at all).
  for _, this in ipairs(self.active) do
    -- We test for the presence of the "radius" property. We also ignore the
    -- "ephemeral" entities (e.g. sparkles, smoke, bubbles, etc...) since
    -- they do not count for collisions.
    if this.radius and not this.ephemeral then
      for _, that in ipairs(self.active) do
        -- We also check if we are testing an item with itself!
        if this ~= that and that.radius and not that.ephemeral and this:collide(that) then
          colliding[#colliding + 1] = { this, that }
        end
      end
    end
  end
  return colliding
end

function Entities:find(filter)
  for _, entity in ipairs(self.active) do
    if filter(entity) then
      return entity
    end
  end
  for _, entity in ipairs(self.incoming) do
    if filter(entity) then
      return entity
    end
  end
  return nil
end

-- END OF MODULE ---------------------------------------------------------------

return Entities

-- END OF FILE -----------------------------------------------------------------
