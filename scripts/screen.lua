screen = class:new({
  x = 0,
  y = 0,

  width = 64,
  height = 64,

  ox = 0,
  oy = 0,

  cx = 0,
  cy = 0,

  dead_zone = {
    x = 0,
    y = 0,
    width = 24,
    height = 64,
  },

  update = function(_ENV)
    if target then
      local tx = target.x + target.width / 2
      local left = tx - dead_zone.x
      local right = left - dead_zone.width
      screen.x = mid(left, screen.x, right)
    end

    x = mid(0, x, max_x)
    cx = x + ox
    cy = y + oy

    camera(cx, cy)
  end,

  follow = function(_ENV, e)
    target = e
  end,

  shake = function(_ENV, pixels, frames)
    pixels = pixels or 3
    frames = frames or 10

    async("screen:shake", function()
      for i = frames, 0, -1 do
        ox = rnd(pixels * i / frames)
        oy = rnd(pixels * i / frames)
        yield()
      end
    end)
  end
})