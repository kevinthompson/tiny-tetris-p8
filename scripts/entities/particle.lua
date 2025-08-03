particle = entity:extend({
  layer = 2,
  color = 7,
  frames = 30,
  radius = 0,

  after_init = function(_ENV)
    max_frames = frames
  end,

  update = function(_ENV)
    if (not aabb(_ENV, screen)) then
      _ENV:destroy()
      return
    end

    frames -= 1

    if frames <= 0 then
      _ENV:destroy()
    else
      vy += gravity * gravity_scale
      x += vx
      y += vy
      sort = layer * 1000 + y
    end
  end,

  draw = function(_ENV)
    local c, r = _ENV.color, radius
    local frames_elapsed = max_frames - frames

    if (type(c) == "table") then
      local frames_per_color = max_frames / #c
      c = c[1 + round(frames_elapsed / frames_per_color)]
    end

    if (type(r) == "table") then
      r = r[1] - (r[1] - r[2]) * (frames_elapsed / max_frames)
    end

    circfill(x,y,r,c)
  end
})