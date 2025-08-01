game = scene:extend({
  init = function(_ENV)
    -- set palette
    pal(split("1,129,139,140,5,6,7,8,9,10,11,12,13,14,15,0"), 1)

    -- create empty grid
    grid = {}
    for y = 1, 16 do
      grid[y] = {0,0,0,0,0,0,0,0,0}
    end

    current_piece = piece({
      data = pieces[1]
    })

    -- select next piece
  end,

  update = function(_ENV)
    -- if current piece
      -- move current piece down
      -- if any part of current piece would hit another block
      -- piece stops and is committed to grid
      -- when piece stops, evaluate completed lines
      -- remove completed lines
      -- increment line count
      -- if line count >= 10 increment level count
      -- if level count > hi update high score
    -- next piece becomes current piece

    for y = 16, 1, -1 do
      local total = 0

      for x = 1, 9 do
        total += grid[y][x]
      end

      if total == 0 and y > 1 then
        grid[y] = grid[y - 1]
        grid[y - 1] = {0,0,0,0,0,0,0,0,0}
      end
    end

  end,

  draw = function(_ENV)
    cls(2)

    -- draw background
    local step = 4
    local period = 12
    local speed = 5
    local amp = 1.5
    local offset = t() * speed

    for y = -step, 64, step do
      for x = 0, 64 do
        if x == 0 or x >= 48 then
          local py = (offset / 2) % step + y + sin((x + offset)/period) * amp
          pset(x, py, 1)
        end
      end
    end

    -- draw play area
    rectfill(2,0,47,61,0)
    line(1,0,1,61,6)
    line(48,0,48,61,6)
    line(2,62,47,62,6)

    -- draw grid
    for iy, row in ipairs(grid) do
      local y = -18 + (iy - 1) * 5

      for ix = 1, 9 do
        local x = 3 + (ix - 1) * 5
        spr(grid[iy][ix], x, y)
      end
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
    {1, 0, 0 },
    {1, 1, 1 },
    {0, 0, 0 },
  },
  {
    {0, 0, 1 },
    {1, 1, 1 },
    {0, 0, 0 },
  },
  {
    { 0, 1, 0, 0 },
    { 0, 1, 0, 0 },
    { 0, 1, 0, 0 },
    { 0, 1, 0, 0 },
  },
  {
    { 1, 1, 0 },
    { 0, 1, 1 },
    { 0, 0, 0 },
  },
  {
    { 0, 1, 1, 0 },
    { 0, 1, 1, 0 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
  },
  {
    { 0, 1, 0 },
    { 1, 1, 1 },
    { 0, 0, 0 },
  },
  {
    { 0, 1, 1 },
    { 1, 1, 0 },
    { 0, 0, 0 },
  }
}

piece = entity:extend({
  x = 4,
  y = 1,
  data = {},

  after_init = function(_ENV)
    drop_timer = 60
  end,

  update = function(_ENV)
    local nx = x
    local ny = y

    drop_timer -= 1

    if (btnp(0)) nx -= 1
    if (btnp(1)) nx += 1
    if (btnp(2)) _noop() -- todo: quick drop
    if (btnp(4)) _ENV:rotate(-1)
    if (btnp(5)) _ENV:rotate(1)

    -- move down
    if drop_timer <= 0 or btnp(3) then
      ny += 1
      drop_timer = 60
    end

    -- todo: if position valid
    x = nx
    y = ny
    -- else
    -- copy current position to grid
    -- spawn next piece
  end,

  rotate = function(_ENV, dir)
    local rows = #data
    local cols = #data[1]

    local new_data = {}
    for r = 1, rows do
      new_data[r] = {}
    end

    for r = 1, rows do
      for c = 1, cols do
        if dir == 1 then
          new_data[c][rows + 1 - r] = data[r][c]
        else
          new_data[cols + 1 - c][r] = data[r][c]
        end
      end
    end

    data = new_data
  end,

  draw = function(_ENV)
    for iy, row in ipairs(data) do
      local sy = -18 + (y + iy - 1) * 5

      for ix, value in ipairs(row) do
        local sx = 3 + (x + ix - 1) * 5
        if (value == 1) spr(1, sx, sy)
      end
    end
  end
})