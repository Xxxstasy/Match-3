local field = {{'    0 1 2 3 4 5 6 7 8 9'}, 
            {"  ----------------------"},
            {"0 |"},
            {"1 |"},
            {"2 |"},
            {"3 |"},
            {"4 |"},
            {"5 |"},
            {"6 |"},
            {"7 |"},
            {"8 |"},
            {"9 |"}}

local matrix = {{},
                {},
                {},
                {},
                {},
                {},
                {},
                {},
                {},
                {}}

local UP_BORDER = 0
local DOWN_BORDER = 9
local RIGHT_BORDER = 9
local LEFT_BORDER = 0
local COLORS = 6
local EMPTY_CELL = -4
local MARKED_CELL = -23
local NECESSERY_MATCH = 3
local FIELD_SIZE = 10
local EXIT = 'q'


local function fall() -- checks if any cells has to fall and swap empty cells with the cells above them, if any movements were made returns true, else returns false
  local res = false
  for y = DOWN_BORDER, UP_BORDER + 1, -1 do
    for x = LEFT_BORDER, RIGHT_BORDER do
      if (matrix[y][x] == EMPTY_CELL)and(matrix[y-1][x] ~= EMPTY_CELL) then
        matrix[y][x], matrix[y-1][x] = matrix[y-1][x], matrix[y][x]
        res = true
      end
    end
  end
  
  for x = LEFT_BORDER, RIGHT_BORDER do 
    if matrix[UP_BORDER][x] == EMPTY_CELL then
      res = true
    end
  end
  return res
end

local function fill_top() -- fills empty cells on top of the field with random colors
  for x = LEFT_BORDER,RIGHT_BORDER do 
    if matrix[UP_BORDER][x] == EMPTY_CELL then
      matrix[UP_BORDER][x] = math.random(1,COLORS)
    end
  end
end

local function find_triplets() -- find lines >= 3 of the same colors on the field, put these lines in "triplets" and returns "triplets" 
  local triplets = {}
  for column = 0,RIGHT_BORDER do 
    local lenght = 1
    for row = 1,DOWN_BORDER  do 
      if matrix[row][column] == matrix[row-1][column] then
        lenght = lenght + 1
      end
      if not (matrix[row][column] == matrix[row-1][column]) then
        if lenght >= NECESSERY_MATCH then 
          local match = {}
          for ClearRow = row - lenght, row - 1 do 
            table.insert(match,{ClearRow,column})
          end
          table.insert(triplets,match)
        end
        lenght = 1
      end
      if row ==DOWN_BORDER  then 
        if lenght >= NECESSERY_MATCH then 
          local match = {}
          for ClearRow = row - (lenght - 1), row  do 
            table.insert(match,{ClearRow,column})
          end
          table.insert(triplets,match)
        end
      end
    end
  end        
  for row = 0,DOWN_BORDER  do 
    local lenght = 1
    for column = 1,RIGHT_BORDER  do 
      if matrix[row][column] == matrix[row][column - 1] then
        lenght = lenght + 1
      end
      if not (matrix[row][column] == matrix[row][column - 1 ]) then
        if lenght >= NECESSERY_MATCH then 
          local match = {}
          for ClearColumn = column - lenght, column - 1 do 
            table.insert(match,{row,ClearColumn})
          end
          table.insert(triplets,match)
        end
        lenght = 1
      end
      if column ==RIGHT_BORDER then 
        if lenght >= NECESSERY_MATCH then 
          local match = {}
          for ClearColumn = column - (lenght - 1), column  do 
            table.insert(match,{row, ClearColumn})
          end
          table.insert(triplets,match)
        end
      end
    end
  end
  return triplets
end

local function mark_triplets(triplets) -- marks cells from triplets
  for _,line in pairs(triplets) do
    for _,cell in pairs(line) do
      matrix[cell[1]][cell[2]] = MARKED_CELL
    end
  end
end

local function clear_marked_cells(triplets) -- turns marked cells into an empty cells
  local res = false
  for x = LEFT_BORDER, RIGHT_BORDER do
    for y = UP_BORDER, DOWN_BORDER do
      if matrix[y][x] == MARKED_CELL then
        matrix[y][x] = EMPTY_CELL
        res= true
      end
    end
  end
  return res
end

local function no_possible_triplets(triplets) -- checks if there is no possible triplets on the field, returns true if it's impossible to make a triplet , else returns false
  local triples = {}
  for column = 0,RIGHT_BORDER do 
    for row = 0,DOWN_BORDER do 
      matrix[row][column],matrix[row + 1][column] = matrix[row + 1][column],matrix[row][column]
      triples = find_triplets()
      matrix[row + 1][column],matrix[row][column] = matrix[row][column],matrix[row + 1][column] 
      if next(triples) ~= nil then 
        return false
      end
    end
  end
  for column = 0,RIGHT_BORDER do 
    for row = 0,DOWN_BORDER do 
      matrix[row][column],matrix[row][column + 1] = matrix[row][column + 1],matrix[row][column]
      triples = find_triplets()
      matrix[row][column],matrix[row][column + 1] = matrix[row][column + 1],matrix[row][column]
      if next(triples) ~= nil then 
        return false
      end
    end
  end
  return true
end

local function turn(input) --handles user's input and returns from,to
  if input == EXIT then
    return EXIT
  end
  local y, x, dir = string.match(input, 'm (%d+) (%d+) ([l,r,u,d])')
  if (x == nil) or (y == nil) then 
    io.write("invalid format\n")
    return false
  end
  local from = {tonumber(y),tonumber(x)}
  local to
  if dir == "l" then 
    to = {from[1] , from[2] - 1}
  elseif dir == "r" then 
    to = {from[1] , from[2] + 1}
  elseif dir == "u" then 
    to = {from[1] - 1, from[2]}
  else
    to = {from[1] + 1, from[2]}
  end
  return from,to
end

local function init()
  for y = UP_BORDER, DOWN_BORDER do
    matrix[y] = {}
    for x = LEFT_BORDER, RIGHT_BORDER do
      matrix[y][x] = math.random(0,COLORS - 1)
    end
  end
  local triples = find_triplets()
  if no_possible_triplets() == true or (#triples ~= 0) then
    init()
  end
end

local function tick()
  if fall() then
    fill_top()
    return true
  end
  if clear_marked_cells() then 
    return true
  end
  local triples = find_triplets()
  if #triples ~= 0 then 
    mark_triplets(triples)
    return true
  end
  return false
end
  
local function move(from,to)
  if (from[1] < LEFT_BORDER) or (from[1] > RIGHT_BORDER) or (from[2] < UP_BORDER) or (from[2] > DOWN_BORDER) or (to[1] < LEFT_BORDER) or (to[1] > RIGHT_BORDER) or (to[2] < UP_BORDER) or (to[2] > DOWN_BORDER) then
    io.write('Out of range')
    return false
  end
  matrix[from[1]][from[2]], matrix[to[1]][to[2]] = matrix[to[1]][to[2]], matrix[from[1]][from[2]]
  local res = find_triplets()
  if #res == 0 then
    io.write('There is no matches')
    io.write('\n')
    matrix[from[1]][from[2]], matrix[to[1]][to[2]] = matrix[to[1]][to[2]], matrix[from[1]][from[2]]
    return false
  else
    return true
  end
end

local function mix()
  while (next(triplets) ~= nil) or (no_possible_triplets() == true) do 
    for i = 1, FIELD_SIZE^2 do
      local x1 = math.random(LEFT_BORDER,RIGHT_BORDER)
      local x2 = math.random(LEFT_BORDER,RIGHT_BORDER)
      local y1 = math.random(UP_BORDER,DOWN_BORDER)
      local y2 = math.random(UP_BORDER,DOWN_BORDER)
      matrix[y1][x1], matrix[y2][x2] = matrix[y2][x2], matrix[y1][x1]
    end
  end
end

local function dump()
  for x = LEFT_BORDER, RIGHT_BORDER do 
    for y = UP_BORDER, DOWN_BORDER do
      field[y+3][x+2] = string.char(string.byte("A") + matrix[y][x])
    end
  end
  for x1,y1 in pairs(field) do
    for x2,y2 in pairs(y1) do
      io.write(y2 .. ' ')
    end
    io.write('\n')
  end
  io.write('\n')
end

init()
dump()

while input ~= EXIT do
  repeat
  io.write("To make a turn write m x(0-9) y(0-9) direction(r,l,u,d)\n")
  input = io.read()
  from,to = turn(input)
  until from ~= false

  if move(from,to) == true then
    repeat 
      dump()
    until tick() == false
  end
  if no_possible_triplets() == true then
    mix()
  end
end