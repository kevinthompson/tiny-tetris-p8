game = scene:extend({
  init = function(_ENV)
    -- set palette
    pal(split("1,129,139,140,5,6,7,8,9,10,11,12,13,14,15,0"), 1)

    -- create grid
    grid = {}
    for y = 1, 144 do
      add(grid, 1)
    end
  end,

  update = function(_ENV)
  end,

  draw = function(_ENV)
    cls(2)

    -- draw background
    local step = 4
    local period = 12
    local speed = 5
    local amp = 1.5

    -- todo: improve performance
    for y = -step, 64, step do
      for x = 0, 64 do
        pset(x, (t() * speed / 2) % step + y + sin((x + t() * speed)/period) * amp, 1)
      end
    end

    -- draw play area
    rectfill(2,0,47,61,0)
    line(1,0,1,61,6)
    line(48,0,48,61,6)
    line(2,62,47,62,6)

    -- draw grid
    for i = 1, #grid do
      local x = 3 + ((i - 1) % 9) * 5
      local y = -18 + ((i - 1) \ 9) * 5
      spr(grid[i], x, y)
    end

    -- draw next piece
    spr(49, 51, 2, 2, 1)
    spr(23, 51, 6)

    -- draw line count
    spr(35, 51, 26, 2, 1)
    ? lpad(0), 51, 30, 7

    -- draw level number
    spr(33, 51, 39, 2, 1)
    ? lpad(0), 51, 43, 7

    -- draw high score
    spr(51, 51, 52, 2, 1)
    ? lpad(0), 51, 56, 7

    entity:each("draw")
  end,
})

pieces = {
  {
    1, 1, 0, 0,
    1, 0, 0, 0,
    1, 0, 0, 0,
    0, 0, 0, 0,
  },
  {
    1, 1, 0, 0,
    0, 1, 0, 0,
    0, 1, 0, 0,
    0, 0, 0, 0,
  },
  {
    1, 0, 0, 0,
    1, 0, 0, 0,
    1, 0, 0, 0,
    1, 0, 0, 0,
  },
  {
    0, 1, 0, 0,
    1, 1, 0, 0,
    1, 0, 0, 0,
    0, 0, 0, 0,
  },
  {
    1, 1, 0, 0,
    1, 1, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
  },
  {
    1, 0, 0, 0,
    1, 1, 0, 0,
    1, 0, 0, 0,
    0, 0, 0, 0,
  },
  {
    1, 0, 0, 0,
    1, 1, 0, 0,
    0, 1, 0, 0,
    0, 0, 0, 0,
  }
}