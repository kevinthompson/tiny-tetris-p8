title = scene:extend({
  init = function(_ENV)
  end,

  update = function(_ENV)
    if not loading and btnp(5) then
      scene:load(game)
    end
  end,

  draw = function(_ENV)
    cls(1)
    printc("tiny tetris", 16, 7)
    printc("x start", 32, 6)
  end
})
