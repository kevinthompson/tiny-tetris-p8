game = scene:extend({
  init = function(_ENV)
    -- define line clear points
    line_clear_points = {1, 3, 6, 10}
    line_clear_sfx = {6, 7, 8, 9}

    -- create empty grid
    grid = {}
    for y = 1, 18 do
      add(grid, {0,0,0,0,0,0,0,0,0})
    end

    -- initial game state
    max_music_speed = 16
    min_music_speed = 8
    line_offset = 0
    max_drop_timer = 60
    max_timer_resets = 15
    points = 0
    lines = 0
    level = 1

    _ENV:set_music_speed(max_music_speed)

    -- setup piece bag
    piece_index = 1
    piece_bag = shuffle({1,2,3,4,5,6,7})

    -- load first piece
    async(function()
      wait(30)
      music(0)
    end)

    _ENV:load_next_piece()
  end,

  update = function(_ENV)
    if current_piece then
      drop_timer += 1

      -- rotate counter-clockwise
      if btnp(4) then
        sfx(1)
        if _ENV:rotate_current_piece(-1) then
          _ENV:reset_drop_timer()
        end

      -- rotate clockwise
      elseif btnp(5) then
        sfx(1)
        if _ENV:rotate_current_piece(1) then
          _ENV:reset_drop_timer()
        end

      -- handle movement
      else
        local cx = current_piece.x
        local cy = current_piece.y

        -- move left
        if btnp(0) then
          sfx(2)
          cx -= 1

        -- move right
        elseif btnp(1) then
          sfx(2)
          cx += 1

        -- quick drop
        elseif btnp(2) then
          sfx(10)

          while _ENV:valid_position(cx, cy) do
            current_piece.y = cy
            cy += 1
          end

        -- move down
        elseif btnp(3) then
          cy += 1
          sfx(2)
        elseif drop_timer >= max_drop_timer then
          cy += 1
        end

        -- apply movement if valid
        if _ENV:valid_position(cx, cy) then
          _ENV:move_current_piece(cx, cy)

        -- handle invalid drop
        elseif cy > current_piece.y then
          _ENV:add_current_piece_to_grid()
          _ENV:clear_completed_lines(function()
            -- check for invalid lines
            for y = 1, 6 do
              for x = 1, #grid[1] do
                if grid[y][x] != 0 then
                  scene:load(game_over)
                  return
                end
              end
            end

            -- load next piece
            _ENV:load_next_piece()
          end)
        end
      end
    end

    -- update high score
    if points > dget(0) then
      dset(0, points)
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

      for i in all(line_indexes) do
        if (i > iy) row_offset += line_offset
      end

      local y = -28 + (iy - 1) * 5 + row_offset

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
    ? lpad(points), 51, 56, points >= dget(0) and 10 or 7

    -- flash if about the be placed
    if current_piece then
      current_piece.flashing = not _ENV:valid_position(current_piece.x, current_piece.y + 1)
    end

    entity:each("draw")
  end,

  load_next_piece = function(_ENV)
    current_piece = piece({ id = piece_bag[piece_index] })
    preview = piece({ id = current_piece.id, preview = true })
    piece_index += 1

    if piece_index > #piece_bag then
      piece_bag = shuffle({1,2,3,4,5,6,7})
      piece_index = 1
    end

    next_piece = piece_bag[piece_index]
    max_y = current_piece.y
    drop_timer = 0
    timer_resets = 0
  end,

  move_current_piece = function(_ENV, x, y)
    if (current_piece.x != x) _ENV:reset_drop_timer()
    if (current_piece.y != y) drop_timer = 0

    -- only reset timer limit on new row
    if y > max_y then
      max_y = y
      timer_resets = 0
    end

    -- update current piece position
    current_piece.x = x
    current_piece.y = y

    -- update preview
    preview.x = x
    preview.y = y
    preview.data = current_piece.data

    -- move preview down until it's not valid
    while _ENV:valid_position(preview.x, preview.y)
    and preview.y <= #grid do
      preview.y += 1
    end

    preview.y -= 1
  end,

  rotate_current_piece = function(_ENV, dir)
    local cx, cy = current_piece.x, current_piece.y
    current_piece:rotate(dir)

    -- return if rotation is valid
    if _ENV:valid_position(cx, cy) then
      return true
    end

    -- attempt to move rotated piece to a valid position
    local potential_moves = {
      {0, -1},
      {0, -2},
      {-1, -1},
      {1, -1},
      {-1, 0},
      {1, 0},
      {-2, 0},
      {2, 0}
    }

    for offset in all(potential_moves) do
      if _ENV:valid_position(cx + offset[1], cy + offset[2]) then
        current_piece.x += offset[1]
        current_piece.y += offset[2]
        return true
      end
    end

    -- undo rotation
    current_piece:rotate(dir * -1)
    return false
  end,

  valid_position = function(_ENV, x, y)
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

    sfx(0)

    -- destroy current piece entities
    current_piece:destroy()
    current_piece = nil
    preview:destroy()
    preview = nil
  end,

  clear_completed_lines = function(_ENV, callback)
    local line_indexes = {}

    for y = #grid, 1, -1 do
      local total = 0

      for x = 1, #grid[1] do
        if (grid[y][x] != 0) total += 1
      end

      if total == #grid[1] then
        add(line_indexes, y)
      end
    end

    -- increase points
    if #line_indexes > 0 then
      local index = min(4,#line_indexes)
      points += line_clear_points[index]
      sfx(line_clear_sfx[index])
    end

    -- increase line count
    lines += #line_indexes

    -- load next level
    if lines >= 10 then
      _ENV:load_next_level()
    end

    _ENV:animate_line_clear(line_indexes, callback)
  end,

  load_next_level = function(_ENV)
    -- todo: level change animation
    level += 1
    lines = 0

    -- increase drop speed
    max_drop_timer *= 0.8

    -- increase music speed
    _ENV:set_music_speed(16 - (level - 1) / 2)
  end,

  set_music_speed = function(_ENV, speed)
    for sfx = 11, 19 do
      poke(0x3200 + 68 * sfx + 65, mid(min_music_speed, speed, max_music_speed))
    end
  end,

  reset_drop_timer = function(_ENV)
    local valid_drop = _ENV:valid_position(current_piece.x, current_piece.y + 1)

    if not valid_drop and timer_resets < max_timer_resets then
      timer_resets += 1
      drop_timer = 0
    end
  end,

  animate_line_clear = function(_ENV, line_indexes, callback)
    async(function()
      -- iterate over each line
      for x = 1, #grid[1] do
        for y in all(line_indexes) do
          for i = 1, 3 do

            -- spawn particles
            particle({
              x = 1 + x * 5,
              y = -30 + y * 5,
              frames = 25 + rnd(10),
              gravity_scale = -0.25,
              radius = {2, 0},
              color = {10,7},
              vy = 0,
              vx = -0.5 + rnd()
            })
          end

          -- change line color
          grid[y][x] = 9
        end

        yield()
      end

      -- make lines black
      for x = 1, #grid[1] do
        for y in all(line_indexes) do
          grid[y][x] = 0
        end
      end

      -- animate lines falling
      if #line_indexes > 0 then
        local frames = 5
        for i = 1, frames do
          line_offset = lerp(0, 5, ease_in(i/frames))
          yield()
        end
      end

      -- remove empty lines
      for y in all(line_indexes) do
        deli(grid, y)
      end

      -- fill grid with empty rows
      while #grid < 18 do
        add(grid, {0,0,0,0,0,0,0,0,0}, 1)
      end

      -- reset visual offset
      line_offset = 0

      -- call callback when complete
      callback()
    end)
  end
})
