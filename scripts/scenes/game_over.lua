game_over = scene:extend({
  init = function(_ENV)
  end,

  update = function(_ENV)
    if not loading and btnp(5) then
      transition(function()
        scene:load(title)
      end)
    end
  end,

  draw = function(_ENV)
    game:draw()
    printc("game over scene", 28, 7)
  end,
})