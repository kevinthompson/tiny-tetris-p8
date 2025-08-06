game_over = scene:extend({
  init = function(_ENV)
    local grid = game.grid

    async(function()
      for y = #grid, 1, -1 do
        for x = 1, #grid[1] do
          if grid[y][x] != 0 then
            grid[y][x] = 25
          end
        end
        wait(5)
      end
    end)
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
    rectfill(2, 12, 47, 20, 0)
    ? "game over", 7, 14, 7

    -- prompt
    rectfill(2, 42, 47, 50, 0)

    if flr(t() * 2) % 2 == 0 then
      spr(10, 11, 43)
      ? "again", 20, 44, 7
    end
  end,
})