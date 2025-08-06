piece = entity:extend({
  x = 4,
  y = 5,
  data = {},
  preview = false,
  rotation_index = 1,

  after_init = function(_ENV)
    data = dictionary[id][rotation_index]
    layer = preview and 1 or 2
  end,

  draw = function(_ENV)
    local sprite = preview and 8 or id

    if not preview and flashing and flr(t() * 10) % 2 == 0 then
      sprite += 32
    end

    for dy = 1, #data do
      local sy = -28 + (y + dy - 2) * 5

      for dx = 1, #data[1] do
        local sx = 3 + (x + dx - 2) * 5
        if (data[dy][dx] == 1) spr(sprite, sx, sy)
      end
    end
  end,

  rotate = function(_ENV, dir)
    local rotations = #dictionary[id]
    rotation_index = rotation_index + dir

    if (rotation_index > rotations) rotation_index = 1
    if (rotation_index < 1) rotation_index = rotations

    data = dictionary[id][rotation_index]
  end,

  dictionary = {
    -- J piece
    {
      {
        {1, 0, 0 },
        {1, 1, 1 },
        {0, 0, 0 },
      },
      {
        {0, 1, 1 },
        {0, 1, 0 },
        {0, 1, 0 },
      },
      {
        {0, 0, 0 },
        {1, 1, 1 },
        {0, 0, 1 },
      },
      {
        {0, 1, 0 },
        {0, 1, 0 },
        {1, 1, 0 },
      },
    },

    -- L piece
    {
      {
        {0, 0, 1 },
        {1, 1, 1 },
        {0, 0, 0 },
      },
      {
        {0, 1, 0 },
        {0, 1, 0 },
        {0, 1, 1 },
      },
      {
        {0, 0, 0 },
        {1, 1, 1 },
        {1, 0, 0 },
      },
      {
        {1, 1, 0 },
        {0, 1, 0 },
        {0, 1, 0 },
      },
    },

    -- I piece
    {
      {
        { 0, 0, 0, 0 },
        { 1, 1, 1, 1 },
        { 0, 0, 0, 0 },
        { 0, 0, 0, 0 },
      },
      {
        { 0, 0, 1, 0 },
        { 0, 0, 1, 0 },
        { 0, 0, 1, 0 },
        { 0, 0, 1, 0 },
      }
    },

    -- Z piece
    {
      {
        { 1, 1, 0 },
        { 0, 1, 1 },
        { 0, 0, 0 },
      },
      {
        { 0, 0, 1 },
        { 0, 1, 1 },
        { 0, 1, 0 },
      },
    },

    -- O piece
    {
      {
        { 1, 1 },
        { 1, 1 },
      }
    },

    -- T piece
    {
      {
        { 0, 1, 0 },
        { 1, 1, 1 },
        { 0, 0, 0 },
      },
      {
        { 0, 1, 0 },
        { 0, 1, 1 },
        { 0, 1, 0 },
      },
      {
        { 0, 0, 0 },
        { 1, 1, 1 },
        { 0, 1, 0 },
      },
      {
        { 0, 1, 0 },
        { 1, 1, 0 },
        { 0, 1, 0 },
      },
    },

    -- S piece
    {
      {
        { 0, 1, 1 },
        { 1, 1, 0 },
        { 0, 0, 0 },
      },
      {
        { 0, 1, 0 },
        { 0, 1, 1 },
        { 0, 0, 1 },
      }
    }
  }
})

