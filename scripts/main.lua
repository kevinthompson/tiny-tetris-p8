poke(0x5f2e, 1)   -- enable alternate palette
poke(0x5f5c, 255) -- disable key repeat
poke(0x5f2c, 3)   -- set resolution to 64x64

-- setup global references
global = _ENV

-- config
entity.gravity_scale = 0
custom_transition_table = [[
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  1,1,129,129,129,129,129,129,129,129,0,0,0,0,0
  129,129,129,129,129,129,129,0,0,0,0,0,0,0,0
  139,139,3,3,3,3,3,131,129,129,129,129,0,0,0
  140,140,140,140,131,131,1,1,1,129,129,129,129,0,0
  5,5,133,133,133,133,130,130,128,128,128,128,128,0,0
  6,6,134,13,13,13,141,5,5,5,133,130,128,128,0
  7,6,6,6,134,134,134,134,5,5,5,133,130,128,0
  8,8,136,136,136,136,132,132,132,130,128,128,128,128,0
  9,9,9,4,4,4,4,132,132,132,128,128,128,128,0
  10,10,138,138,138,4,4,4,132,132,133,128,128,128,0
  11,139,139,139,139,3,3,3,3,129,129,129,0,0,0
  12,12,12,140,140,140,140,131,131,131,1,129,129,129,0
  13,13,141,141,5,5,5,133,133,130,129,129,128,128,0
  14,14,14,134,134,141,141,2,2,133,130,130,128,128,0
  15,143,143,134,134,134,134,5,5,5,133,133,128,128,0
]]

-- initialize cartridge
function _init()
  scene:load(game)
end

-- update current scene
function _update60()
  -- update entities
  entity:each("update")

  -- update coroutines
  async:update()

  -- update scene
  scene.current:update()

  -- update camera
  screen:update()

  -- sort entities
  sort(entity.objects, "sort")
end

-- draw current scene
function _draw()
  scene.current:draw()
end