-- parent class for all scenes
scene = game_object:extend({
  -- switch to new scene if different from current
  load = function(_ENV, new_scene)
    if new_scene != current then
      current = new_scene
      current:init()
    end
  end
})
