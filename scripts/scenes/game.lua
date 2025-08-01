game = scene:extend({
  init = function(_ENV)
    -- set palette
    pal(split("1,129,139,140,5,6,7,8,9,10,11,12,13,14,15,0"), 1)

    -- create empty grid
    grid = {}
    for y = 1, 16 do
      add(grid, {0,0,0,0,0,0,0,0,0})
    end

    drop_timer = 60
    lines = 0
    level = 1

    _ENV:set_current_piece()
  end,

  update = function(_ENV)
    local nx = current_piece.x
    local ny = current_piece.y

    drop_timer -= 1

    if (btnp(0)) nx -= 1
    if (btnp(1)) nx += 1
    if (btnp(2)) _noop() -- todo: quick drop
    if (btnp(4)) current_piece:rotate(-1)
    if (btnp(5)) current_piece:rotate(1)

    -- move down
    if drop_timer <= 0 or btnp(3) then
      ny += 1
      drop_timer = 60
    end

    -- apply movement
    if _ENV:is_valid_move(current_piece, nx, ny) then
      current_piece.x = nx
      current_piece.y = ny
    elseif ny > current_piece.y then
      _ENV:add_piece_to_grid(current_piece)
      _ENV:evaluate_lines()
      _ENV:set_current_piece()
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
    spr(next_piece + 16, 51, 6)

    -- draw line count
    spr(35, 51, 26, 2, 1)
    ? lpad(lines), 51, 30, 7

    -- draw level number
    spr(33, 51, 39, 2, 1)
    ? lpad(level), 51, 43, 7

    -- draw high score
    spr(51, 51, 52, 2, 1)
    ? lpad(0), 51, 56, 7

    entity:each("draw")
  end,

  set_current_piece = function(_ENV)
    current_piece = piece({ id = next_piece or _ENV:get_random_piece_id() })
    next_piece = _ENV:get_random_piece_id()
  end,

  get_random_piece_id = function(_ENV)
    return flr(rnd(#piece_data)) + 1
  end,

  is_valid_move = function(_ENV, test_piece, x, y)
    local data = current_piece.data

    for dy = 1, #data do
      for dx = 1, #data[1] do
        if data[dy][dx] == 1 then
          local gy = dy + y - 1
          local gx = dx + x - 1

          if gy > #grid
          or gx < 1
          or gx > #grid[1]
          or grid[gy][gx] != 0 then
            return false
          end
        end
      end
    end

    return true
  end,

  add_piece_to_grid = function(_ENV, grid_piece)
    local gy = grid_piece.y
    local gx = grid_piece.x
    local data = grid_piece.data

    for dy = 1, #data do
      for dx = 1, #data[1] do
        if data[dy][dx] == 1 then
          grid[dy - 1 + gy][dx - 1 + gx] = grid_piece.id
        end
      end
    end

    grid_piece:destroy()
  end,

  evaluate_lines = function(_ENV)
    -- remove completed lines
    -- increment line count
    -- if line count >= 10 increment level count
    -- if level count > hi update high score

    -- remove completed lines
    for y = #grid, 1, -1 do
      local total = 0

      for x = 1, #grid[1] do
        if (grid[y][x] != 0) total += 1
      end

      if total == #grid[1] then
        deli(grid, y)
        lines += 1
      end
    end

    for i = 1, 16 - #grid do
      add(grid, {0,0,0,0,0,0,0,0,0}, 1)
    end
  end
})
