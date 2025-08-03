game = scene:extend({
  init = function(_ENV)
    -- set palette
    pal(split("1,129,139,140,5,6,7,8,9,10,11,12,13,14,15,0"), 1)

    -- define line clear points
    line_points = {1,3,6,10}

    -- create empty grid
    grid_offset = 0
    grid = {}
    for y = 1, 16 do
      add(grid, {0,0,0,0,0,0,0,0,0})
    end

    -- initial game state
    max_drop_timer = 60
    points = 0
    lines = 0
    level = 1

    -- load first piece
    _ENV:load_next_piece()
  end,

  update = function(_ENV)
    if (not current_piece) return

    local cx = current_piece.x
    local cy = current_piece.y

    completed_line_indexes = {}
    drop_timer -= 1

    -- rotate counter-clockwise
    if btnp(4) then
      if _ENV:rotate_current_piece(-1) then
        _ENV:reset_drop_timer()
      end

    -- rotate clockwise
    elseif btnp(5) then
      if _ENV:rotate_current_piece(1) then
        _ENV:reset_drop_timer()
      end

    -- move left
    elseif btnp(0) then
      cx -= 1

    -- move right
    elseif btnp(1) then
      cx += 1

    -- quick drop
    elseif btnp(2) then
      while _ENV:is_valid_position(cx, cy)
      and cy <= #grid do
        cy += 1
      end

      current_piece.y = cy - 1

    -- move down
    elseif drop_timer <= 0 or btnp(3) then
      cy += 1
      _ENV:reset_drop_timer()
    end

    -- apply movement if valid
    if _ENV:is_valid_position(cx, cy) then
      _ENV:move_current_piece(cx, cy)

    -- add piece to grid
    elseif cy > current_piece.y then
      _ENV:add_current_piece_to_grid()
      _ENV:evaluate_lines()
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
      local row_offset = 0

      for i in all(completed_line_indexes) do
        if (i > iy) row_offset += grid_offset
      end

      local y = -18 + (iy - 1) * 5 + row_offset

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

    -- draw points
    spr(37, 51, 52, 2, 1)
    ? lpad(points), 51, 56, 7

    entity:each("draw")
  end,

  load_next_piece = function(_ENV)
    local piece_id = next_piece or _ENV:get_random_piece_id()
    current_piece = piece({ id = piece_id })
    preview = piece({ id = piece_id, preview = true })
    next_piece = _ENV:get_random_piece_id()
    _ENV:reset_drop_timer()
  end,

  get_random_piece_id = function(_ENV)
    return flr(rnd(#piece.dictionary)) + 1
  end,

  move_current_piece = function(_ENV, x, y)
    current_piece.x = x
    current_piece.y = y

    -- update preview
    preview.x = x
    preview.y = y
    preview.data = current_piece.data

    -- move preview down until it's not valid
    while _ENV:is_valid_position(preview.x, preview.y)
    and preview.y <= #grid do
      preview.y += 1
    end

    preview.y -= 1
  end,

  rotate_current_piece = function(_ENV, dir)
    local cx, cy = current_piece.x, current_piece.y
    current_piece:rotate(dir)

    -- return if rotation is valid
    if _ENV:is_valid_position(cx, cy) then
      return true
    end

    -- attempt to move rotated piece to a valid position
    for offset in all({{-1, 0},{1, 0},{0, -1},{0, 1}}) do
      if _ENV:is_valid_position(cx + offset[1], cy + offset[2]) then
        current_piece.x += offset[1]
        current_piece.y += offset[2]
        return true
      end
    end

    -- undo rotation
    current_piece:rotate(dir * -1)
    return false
  end,

  is_valid_position = function(_ENV, x, y)
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

  add_current_piece_to_grid = function(_ENV)
    local cy = current_piece.y
    local cx = current_piece.x
    local data = current_piece.data

    -- one point for each piece placed
    points += 1

    -- add each block to grid
    for dy = 1, #data do
      for dx = 1, #data[1] do
        if data[dy][dx] == 1 then
          local gy = dy - 1 + cy
          local gx = dx - 1 + cx

          -- place block in grid
          grid[gy][gx] = current_piece.id
        end
      end
    end

    -- destroy current piece entities
    current_piece:destroy()
    current_piece = nil
    preview:destroy()
    preview = nil
  end,

  evaluate_lines = function(_ENV)
    completed_line_indexes = _ENV:find_completed_lines()

    -- increase points
    if #completed_line_indexes > 0 then
      points += line_points[min(4,#completed_line_indexes)]
    end

    -- increase line count
    lines += #completed_line_indexes

    -- load next level
    if lines >= 10 then
      _ENV:load_next_level()
    end

    -- remove cleared lines asynchronously
    async(function()
      -- iterate over each line
      for x = 1, #grid[1] do
        for y in all(completed_line_indexes) do
          for i = 1, 3 do

            -- spawn particles
            particle({
              x = 3 + x * 5,
              y = -18 + y * 5,
              frames = 30,
              gravity_scale = 1,
              radius = {2, 0},
              color = {10,7},
              vy = -1.5,
              vx = -1 + rnd(2)
            })
          end

          -- change line color
          grid[y][x] = 9
        end

        yield()
      end

      -- make lines black
      for x = 1, #grid[1] do
        for y in all(completed_line_indexes) do
          grid[y][x] = 0
        end
      end

      -- animate lines falling
      if #completed_line_indexes > 0 then
        local frames = 5
        for i = 1, frames do
          grid_offset = lerp(0, 5, ease_in(i/frames))
          yield()
        end
      end

      -- remove empty lines
      for y in all(completed_line_indexes) do
        deli(grid, y)
      end

      -- fill grid with empty rows
      while #grid < 16 do
        add(grid, {0,0,0,0,0,0,0,0,0}, 1)
      end

      -- reset visual offset
      grid_offset = 0

      -- check for invalid lines
      for y = 1, 4 do
        for x = 1, #grid[1] do
          if grid[y][x] != 0 then
            _ENV:handle_game_over()
            return
          end
        end
      end

      -- load next piece
      _ENV:load_next_piece()
    end)
  end,

  find_completed_lines = function(_ENV)
    local result = {}

    -- remove completed lines
    for y = #grid, 1, -1 do
      local total = 0

      for x = 1, #grid[1] do
        if (grid[y][x] != 0) total += 1
      end

      if total == #grid[1] then
        add(result, y)
      end
    end

    return result
  end,

  load_next_level = function(_ENV)
    -- todo: level change animation

    -- increase drop speed
    max_drop_timer *= 0.9

    -- update high score
    if points > dget(0) then
      dset(0, points)
    end

    level += 1
    lines = 0
  end,

  reset_drop_timer = function(_ENV)
    drop_timer = max_drop_timer
  end,

  handle_game_over = function(_ENV)
    -- todo: game over
    extcmd("reset")
  end
})
