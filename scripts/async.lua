async = class:extend({
  -- initialize empty collection of coroutines
  coroutines = {},

  -- allow table to be called as a function
  -- ex: async(function() --... end)
  __call = function(_ENV, key, func)
    -- named key is optional
    if type(key) == "function" then
      func = key
      key = nil
    end

    -- delete current named coroutine if key is not nil
    if (key != nil) _ENV:delete(key)

    -- add coroutine to collection
    return add(coroutines, { key, cocreate(func) })
  end,

  init = function(_ENV)
    _ENV:reset()
  end,

  reset = function(_ENV)
    coroutines = {}
  end,

  update = function(_ENV, routines)
    -- update all coroutines
    for r in all(coroutines) do
      -- check if coroutines is complete
      if costatus(r[2]) != "dead" then
        -- run next loop of coroutine
        assert(coresume(r[2]))
      else
        -- delete finished ("dead") coroutine
        del(coroutines, r)
      end
    end
  end,

  -- delete coroutine by named key or routine
  delete = function(_ENV, key_or_routine)
    if type(key_or_routine) == "string" then
      for r in all(coroutines) do
        if r[1] == key_or_routine then
          del(coroutines, r)
        end
      end
    else
      del(coroutines, routine)
    end
  end
})

-- helper function to wait x frames in coroutines
function wait(frames)
  for i = 1, frames do
    yield()
  end
end