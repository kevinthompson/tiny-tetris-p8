-- parent class for objects with lifecycle loop
game_object = class:extend({
  init = function(_ENV)
    _ENV.async = async:new()
  end,

  update = function(_ENV)
    async:update()
  end,

  draw = _noop,
  destroy = _noop
})
