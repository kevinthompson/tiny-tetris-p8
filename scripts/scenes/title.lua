title = scene:extend({
  init = function(_ENV)
    stars = {}

    for i = 1, 16 do
      local y = 4 + rnd(20)

      add(stars, entity({
        x = 8 + rnd(48),
        y = y + (y > 12 and 24 or 0),
        color = rnd({ 1, 2 }),
        width = 1,
        height = 1,
      }))
    end
  end,

  update = function(_ENV)
    if not loading and btnp(5) then
      sfx(5)
      transition(function()
        entity:each("destroy")
        scene:load(game)
      end)
    end
  end,

  draw = function(_ENV)
    cls(0)

    -- draw stars
    entity:each("draw")
    spr(11, 42, 4)
    spr(11, 11, 39)

    -- border
    line(2,1,61,1,13)
    line(2,62,61,62,13)
    line(1,2,1,61,13)
    line(62,2,62,61,13)

    -- logo
    spr(65, 5, 6, 7, 5)

    -- prompt
    if flr(t() * 2) % 2 == 0 then
      spr(10, 18, 43)
      ? "start", 27, 44, 7
    end

    -- high score
    ? "hiscore", 12, 54, 2
    ? lpad(dget(0),3), 42, 54, 1
  end
})
