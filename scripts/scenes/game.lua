game = scene:extend({
  init = function(_ENV)
  end,

  update = function(_ENV)
  end,

  draw = function(_ENV)
    cls()
    entity:each("draw")
    printc("game scene", 28, 7)
  end,
})