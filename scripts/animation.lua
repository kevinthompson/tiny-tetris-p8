function animate(_ENV, values, frames, easing)
  frames = frames or 30
  easing = easing or ease_out

  local initial = {}
  for key, _ in pairs(values) do
    initial[key] = _ENV[key]
  end

  async(function()
    for i = 1, frames do
      for key, value in pairs(values) do
        _ENV[key] = lerp(initial[key], value, easing(i / frames))
      end

      yield()
    end
  end)
end

function ease_in(t)
	return t^2
end

function ease_out(t)
	return 1 - (t - 1)^2
end

function ease_in_out(t)
  return t < .5 and 2 * t^2 or 1 - 2 * (t - 1)^2
end