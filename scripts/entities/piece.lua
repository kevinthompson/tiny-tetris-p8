piece = entity:extend({
  x = 4,
  y = 3,
  data = {},
  preview = false,

  after_init = function(_ENV)
    data = piece_data[id]
    layer = preview and 1 or 2
  end,

  draw = function(_ENV)
    for dy = 1, #data do
      local sy = -18 + (y + dy - 2) * 5

      for dx = 1, #data[1] do
        local sx = 3 + (x + dx - 2) * 5
        if (data[dy][dx] == 1) spr(preview and 8 or id, sx, sy)
      end
    end
  end,

  rotate = function(_ENV, dir)
    local rows = #data
    local cols = #data[1]

    local new_data = {}
    for r = 1, rows do
      new_data[r] = {}
    end

    for r = 1, rows do
      for c = 1, cols do
        if dir == 1 then
          new_data[c][rows + 1 - r] = data[r][c]
        else
          new_data[cols + 1 - c][r] = data[r][c]
        end
      end
    end

    data = new_data
  end,
})

piece_data = {
  {
    {1, 0, 0 },
    {1, 1, 1 },
    {0, 0, 0 },
  },
  {
    {0, 0, 1 },
    {1, 1, 1 },
    {0, 0, 0 },
  },
  {
    { 0, 0, 0, 0 },
    { 1, 1, 1, 1 },
    { 0, 0, 0, 0 },
    { 0, 0, 0, 0 },
  },
  {
    { 1, 1, 0 },
    { 0, 1, 1 },
    { 0, 0, 0 },
  },
  {
    { 1, 1 },
    { 1, 1 },
  },
  {
    { 0, 1, 0 },
    { 1, 1, 1 },
    { 0, 0, 0 },
  },
  {
    { 0, 1, 1 },
    { 1, 1, 0 },
    { 0, 0, 0 },
  }
}
