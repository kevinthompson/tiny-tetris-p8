poke(0x5f2e, 1)   -- enable alternate palette
poke(0x5f5c, 255) -- disable key repeat
poke(0x5f2c, 3)   -- set resolution to 64x64

-- setup global references
global = _ENV

-- initialize cartridge
function _init()
scene:load(splash)
end

-- update current scene
function _update60()
  -- update entities
  entity.visible = {}
  entity:each("update")
  sort(entity.visible, "sort")

  -- update coroutines
  async:update()

  -- update scene
  scene.current:update()

  -- update camera
  screen:update()
end

-- draw current scene
function _draw()
  scene.current:draw()
end