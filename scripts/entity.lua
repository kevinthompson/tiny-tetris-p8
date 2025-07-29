entity = game_object:extend({
  gravity = 0.2,
  objects = {},

  each = function(_ENV, func)
    for e in all(objects) do
      e[func](e)
    end
  end,

  --------------------

  -- position
  x=0,
  y=0,
  width = 8,
  height = 8,
  layer = 1,

  vx=0,
  vy=0,
  speed = 1,
  gravity_scale = 1,

  -- collision
  collision = {},
  collides_with = {},

  -- drawing
  color = 7,
  flip = false,
  sx = 0,
  sy = 0,

  -- animation
  fps = 6,
  animations = {
    idle = {0}
  },

  -- state
  state = "default",
  states = {},

  -- events
  on_collide = _noop,
  on_hit = _noop,

  after_init = _noop,
  before_update = _noop,
  after_update = _noop,
  before_destroy = _noop,
  after_destroy = _noop,
  before_draw = _noop,
  after_draw = _noop,

  extend = function(_ENV,tbl)
    tbl = class.extend(_ENV, tbl)
    tbl.objects = {}
    return tbl
  end,

  -- instance methods
  init = function(_ENV)
    game_object.init(_ENV)
    add(entity.objects,_ENV)

    if objects != entity.objects then
      add(objects,_ENV)
    end

    sort = layer * 1000 + y

    _ENV:after_init()
  end,

  update = function(_ENV)
    _ENV:before_update()
    game_object.update(_ENV)

    -- movement
    vy += gravity * gravity_scale
    collision = _ENV:move(x + vx, y + vy)

    -- visibility
    sort = layer * 1000 + y
    visible = aabb(_ENV, screen)

    if visible then
      add(entity.visible, _ENV)
    elseif destroy_off_screen then
      e:destroy()
    end

    _ENV:after_update()
  end,

  draw = function(_ENV)
    if (flashing) pal(split"7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7")

    _ENV:before_draw()
    if sprite then
      spr(sprite, x + sx, y + sy, 1, 1, flip)
    else
      _ENV:draw_shape()
    end

    _ENV:after_draw()

    if (flashing) pal(split"1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0")
  end,

  draw_shape = function(_ENV)
    rectfill(x + sx, y + sy, x + sx + width - 1, y + sy + height - 1, _ENV.color)
  end,

  destroy = function(_ENV)
    _ENV:before_destroy()

    del(entity.objects,_ENV)
    if objects != entity.objects then
      del(objects,_ENV)
    end

    _ENV:after_destroy()
  end,

  animate = function(_ENV, name)
    local animation = animations[name]

    if (animation != current_animation) then
      current_animation = animation
      animation_frame = 1
      animation_timer = fps
    else
      animation_timer -= 1

      if animation_timer <= 0 then
        animation_frame = animation_frame + 1
        animation_timer = fps
      end

      if animation_frame > #current_animation then
        animation_frame = 1
      end
    end

    sprite = current_animation[animation_frame]
  end,

  move = function(_ENV, nx, ny)
    if (nx > x) flip = false
    if (nx < x) flip = true

    -- move without collision
    if #collides_with == 0 then
      x = nx
      y = ny
      return {} -- no collision
    end

    -- move with collision
    local result = {}
    local collision_attributes = {
      {axis = "y", size = "height", value = ny},
      {axis = "x", size = "width", value = nx},
    }

    -- evaluate each axis
    for attrs in all(collision_attributes) do
      local axis, size, value = attrs.axis, attrs.size, attrs.value
      local dir = sgn(value - _ENV[axis])
      local collision_object = nil

      -- step through movement to avoid tunneling
      while _ENV[axis] != value and not collision_object do
        local step = min(_ENV[size], abs(value - _ENV[axis])) * dir
        local cx = x + (axis == "x" and step or 0)
        local cy = y + (axis == "y" and step or 0)
        local x1, y1 = cx, cy
        local x2, y2 = x1 + width, y1 + height

        for e in all(entity.objects) do
          if e != _ENV and _ENV:collides_with_object(e) then
            if x1 < e.x + e.width and x2 > e.x and y1 < e.y + e.height and y2 > e.y then
              if e.solid or e.semi_solid then
                if e.solid
                or (
                  axis == "y"
                  and vy > 0
                  and y + height - 1 < e.y
                ) then
                  collision_object = e
                  _ENV:on_collide(e, axis)
                  break
                end
              else
                _ENV:on_collide(e, axis)
              end
            end
          end
        end

        -- resolve collision
        if collision_object then
          _ENV[axis] = collision_object[axis] + (dir > 0 and -_ENV[size] or collision_object[size])
        else
          _ENV[axis] += step
        end

        -- assign collision result
        result[axis] = collision_object
      end
    end

    return result
  end,

  move_toward = function(_ENV, target)
    local dx = target.x - x
    local dy = target.y - y

    local a = atan2(dx, dy)
    local ax = cos(a)
    local ay = sin(a)

    local vx = sgn(ax) * min(abs(cos(a) * speed), abs(dx))
    local vy = sgn(ay) * min(abs(sin(a) * speed), abs(dy))

    return _ENV:move(x+vx, y+vy)
  end,

  collides_with_object = function(_ENV, obj)
    for collision_class in all(collides_with) do
      if obj:is(collision_class) then
        return true
      end
    end

    return false
  end,

  hit = function(_ENV, amount)
    _ENV:on_hit()

    if health then
      amount = amount or 1
      health -= amount

      if health <= 0 then
        _ENV:destroy()
      else
        _ENV:flash()
      end
    end
  end,

  flash = function(_ENV, color)
    flashing = true
    async("flash", function()
      wait(3)
      flashing = false
    end)
  end,
})