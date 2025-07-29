
transition = class:extend({
  __call = function(_ENV, callback)
    global.loading = true
    callback = callback or _noop
    transition:fade_out(function()
      callback()
      transition:fade_in(function()
        global.loading = false
      end)
    end)
  end,

  fade_in = function(_ENV, callback)
    _ENV:fade(16,0,callback)
  end,

  fade_out = function(_ENV, callback)
    _ENV:fade(0,16,callback)
  end,

  fade = function(_ENV, first, last, callback)
    local dir = last > first and 1 or -1
    async(function()
      for i = first, last, dir do
        _ENV:step(i)
        yield()
      end
      if (callback) callback()
    end)
  end,

  step = function(_ENV, i)
    local fadetable = {}
    local table = transition_table or default_transition_table

    for row in all(split(table, "\n")) do
      add(fadetable, split(row))
    end

    for c = 0, 15 do
      if flr(i + 1) >= 16 then
        pal(c, 0, 1)
      else
        pal(c, fadetable[c + 1][flr(i + 1)], 1)
      end
    end
  end,

  default_transition_table = [[
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    1,1,129,129,129,129,129,129,129,129,0,0,0,0,0
    2,2,2,130,130,130,130,130,128,128,128,128,128,0,0
    3,3,3,131,131,131,131,129,129,129,129,129,0,0,0
    4,4,132,132,132,132,132,132,130,128,128,128,128,0,0
    5,5,133,133,133,133,130,130,128,128,128,128,128,0,0
    6,6,134,13,13,13,141,5,5,5,133,130,128,128,0
    7,6,6,6,134,134,134,134,5,5,5,133,130,128,0
    8,8,136,136,136,136,132,132,132,130,128,128,128,128,0
    9,9,9,4,4,4,4,132,132,132,128,128,128,128,0
    10,10,138,138,138,4,4,4,132,132,133,128,128,128,0
    11,139,139,139,139,3,3,3,3,129,129,129,0,0,0
    12,12,12,140,140,140,140,131,131,131,1,129,129,129,0
    13,13,141,141,5,5,5,133,133,130,129,129,128,128,0
    14,14,14,134,134,141,141,2,2,133,130,130,128,128,0
    15,143,143,134,134,134,134,5,5,5,133,133,128,128,0
  ]]
  -- generated at http://kometbomb.net/pico8/fadegen.html
})
