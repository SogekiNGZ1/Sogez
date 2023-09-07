UI.Separator()
 
Stairs = {}
Stairs.Exclude = {12099}
Stairs.Click = {1948, 435, 7771, 5542, 8657, 6264, 1646, 1648, 1678, 5291, 1680, 6905, 6262, 1664, 13296, 1067, 13861, 11931, 12097, 1949, 11932, 11115}  

--



function Keys(x)
  return modules.corelib.g_keyboard.isKeyPressed(x)
end

Stairs.postostring = function(pos)
    return(pos.x .. ',' .. pos.y .. ',' .. pos.z)
end

Stairs.getTiles = function(distance)
  if not read then return end
    local tiles = {}
    if not distance then distance = 9 end
    for posX = pos().x - distance, pos().x + distance do
        for posY = pos().y - distance, pos().y + distance do
            local tile = g_map.getTile({x = posX, y = posY, z = pos().z})
            if tile then
                table.insert(tiles, tile)
            end
        end
    end
    return tiles
end

function Stairs.accurateDistance(c)
  if not read then return end
    if type(c) == 'userdata' then
        c = c:getPosition()
    end
    if c then
        if c.x and not c.y then
            return(math.abs(c.x-pos().x))
        elseif c.y and not c.x then
            return(math.abs(c.y-pos().y))
        end
        return(math.abs(pos().x-c.x) + math.abs(pos().y-c.y))
    end
    return false
end

Stairs.Check = {}

Stairs.checkTile = function(tile)
  if not read then return end
    if not tile then
        return false
    elseif type(Stairs.Check[Stairs.postostring(tile:getPosition())]) == 'boolean' then
        return Stairs.Check[Stairs.postostring(tile:getPosition())]
    elseif not tile:getTopUseThing() then
        return false
    end
    local cor = (g_map.getMinimapColor(tile:getPosition()))
    for _, x in pairs(tile:getItems()) do
        if table.find(Stairs.Click, x:getId()) then
            tile.Click = true
        elseif table.find(Stairs.Exclude, x:getId()) then
      Stairs.Check[Stairs.postostring(tile:getPosition())] = false
      return false
    end
    end
    checkcolor = (cor >= 210 and cor <= 213)
    if (checkcolor and not tile:isPathable() and tile:isWalkable()) or tile.Click then
    Stairs.Check[Stairs.postostring(tile:getPosition())] = true
        return true
  else
    Stairs.Check[Stairs.postostring(tile:getPosition())] = false
        return false
    end
end


Stairs.checkAll = function()
  if not read then return end
    local tiles = Stairs.getTiles(9)
    table.sort(tiles, function(a, b)
        return Stairs.accurateDistance(a:getPosition()) < Stairs.accurateDistance(b:getPosition())
    end)
    for y, z in ipairs(tiles) do
        if Stairs.checkTile(z) and findPath(pos(), z:getPosition(), 9, { ignoreCreatures = false, precision = 0, ignoreNonWalkable = true, ignoreNonPathable = true, allowUnseen = true, allowOnlyVisibleTiles = false }) then
            return z
        end
    end
  return false
end

function getClosest(table)
  local closest
  if table and table[1] then
    for v, x in pairs(table) do
      if not closest or getDistanceBetween(closest:getPosition(), player:getPosition()) > getDistanceBetween(x:getPosition(), player:getPosition()) then
        closest = x
      end
    end
  end
  if closest then
    return getDistanceBetween(closest:getPosition(), player:getPosition())
  else
    return false
  end
end

function hasNonWalkable(direc)
  tabela = {}
  for i = 1, #direc do
    local tile = g_map.getTile({x = player:getPosition().x + direc[i][1], y = player:getPosition().y + direc[i][2], z = player:getPosition().z})
    if tile and (not tile:isWalkable() or tile:getTopThing():getName():len() > 0) and tile:canShoot() then
      table.insert(tabela, tile)
    end
  end
  return tabela
end

function getClosestBetween(x, y)
  if x or y then
    if x and not y then
      return 1
    elseif y and not x then
      return 2
    end
  else
    return false
  end
  if x < y then
    return 1
  else
    return 2
  end
end

function getDash(dir)
  local dirs
  local tiles = {}
  if not dir then
    return false
  elseif dir == 'n' then
    dirs = {{0, -1}, {0, -2}, {0, -3}, {0, -4}, {0, -5}, {0, -6}, {0, -7}, {0, -8}}
  elseif dir == 's' then
    dirs = {{0, 1}, {0, 2}, {0, 3}, {0, 4}, {0, 5}, {0, 6}, {0, 7}, {0, 8}}
  elseif dir == 'w' then
    dirs = {{-1, 0}, {-2, 0}, {-3, 0}, {-4, 0}, {-5, 0}, {-6, 0}}
  elseif dir == 'e' then
    dirs = {{1, 0}, {2, 0}, {3, 0}, {4, 0}, {5, 0}, {6, 0}}
  end
  for i = 1, #dirs do
    local tile = g_map.getTile({x = player:getPosition().x + dirs[i][1], y = player:getPosition().y + dirs[i][2], z = player:getPosition().z})
    if tile and Stairs.checkTile(tile) and tile:canShoot() then
      table.insert(tiles, tile)
    end
  end
  if not tiles[1] or getClosestBetween(getClosest(hasNonWalkable(dirs)), getClosest(tiles)) == 1 then
    return false
  else
    return true
  end
end

function checkPos(x, y)
  xyz = g_game.getLocalPlayer():getPosition()
  xyz.x = xyz.x + x
  xyz.y = xyz.y + y
  tile = g_map.getTile(xyz)
  if tile then
    return g_game.use(tile:getTopUseThing())  
  else
    return false
  end
end

macro(1, 'BUGMAP', 'CTRL+S', function()
  if not read or modules.game_console:isChatEnabled() then return end
  if Keys('up') then
    if getDash('n') then
      g_game.walk(0)
    else  
      checkPos(0, -5)
    end
  elseif Keys('right') then
    if getDash('e') then
      g_game.walk(1)
    else
      checkPos(5, 0)
    end
  elseif Keys('down') then
    if getDash('s') then
      g_game.walk(2)
    else
      checkPos(0, 5)
    end
  elseif Keys('left') then
    if getDash('w') then
      g_game.walk(3)
    else
      checkPos(-5, 0)
    end
    end
end)  

read = true
