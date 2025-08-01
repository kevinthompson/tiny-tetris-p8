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
    local cx = current_piece.x
    local cy = current_piece.y

    drop_timer -= 1

    if btnp(0) then
      cx -= 1
    elseif btnp(1) then
      cx += 1
    elseif btnp(2) then
      while _ENV:is_valid_position(current_piece, cx, cy) do
        cy += 1
      end

      current_piece.y = cy - 1
    elseif btnp(4) then
      if _ENV:rotate_current_piece(-1) then
        drop_timer = 60
      end
    elseif btnp(5) then
      if _ENV:rotate_current_piece(1) then
        drop_timer = 60
      end
    end

    -- move down
    if drop_timer <= 0 or btnp(3) then
      cy += 1
      drop_timer = 60
    end

    -- apply movement
    if _ENV:is_valid_position(current_piece, cx, cy) then
      current_piece.x = cx
      current_piece.y = cy
    elseif cy > current_piece.y then
      _ENV:add_piece_to_grid(current_piece)
      _ENV:evaluate_lines()
      _ENV:set_current_piece()
    end

    -- update preview
    preview.x = current_piece.x
    preview.y = current_piece.y
    preview.data = current_piece.data

    while _ENV:is_valid_position(current_piece, preview.x, preview.y) do
      preview.y += 1
    end

    preview.y -= 1
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
        if x == 0 or x >= 48 or y > 56 then
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
    local piece_id = next_piece or _ENV:get_random_piece_id()
    current_piece = piece({ id = piece_id })
    preview = piece({ id = piece_id, preview = true })
    next_piece = _ENV:get_random_piece_id()
  end,

  get_random_piece_id = function(_ENV)
    return flr(rnd(#piece_data)) + 1
  end,

  rotate_current_piece = function(_ENV, dir)
    local cx, cy = current_piece.x, current_piece.y
    current_piece:rotate(dir)

    if _ENV:is_valid_position(current_piece, cx, cy) then
      return true
    end

    for offset in all({{-1, 0},{1, 0},{0, 1}}) do
      if _ENV:is_valid_position(current_piece, cx + offset[1], cy + offset[2]) then
        current_piece.x += offset[1]
        current_piece.y += offset[2]
        return true
      end
    end

    current_piece:rotate(dir * -1)
    return false
  end,

  is_valid_position = function(_ENV, test_piece, x, y)
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
    local py = grid_piece.y
    local px = grid_piece.x
    local data = grid_piece.data

    for dy = 1, #data do
      for dx = 1, #data[1] do
        if data[dy][dx] == 1 then
          local gy = dy - 1 + py
          local gx = dx - 1 + px

          if gy <= 4 then
            extcmd("reset")
          end

          grid[gy][gx] = grid_piece.id
        end
      end
    end

    grid_piece:destroy()
    preview:destroy()
  end,

  evaluate_lines = function(_ENV)
    -- if line count >= 10 increment level count

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

    if lines >= 10 then
      -- todo: level change animation
      -- todo: increase drop speed
      -- todo: high score
      level += 1
      lines %= 10
    end
  end
})
