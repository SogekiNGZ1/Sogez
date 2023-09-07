setDefaultTab("Tools")
macro(100, "tirar follow atk", function()
  if CaveBot.isOn() then
    g_game.setChaseMode(0)
  end
end)

pot = now
local healthId = 902
local healthPercent = 70
macro(200, ".:: POT 90% ::.",  function()
  if (hppercent() <= healthPercent) and pot <= now then
    use(healthId)
  pot = (now + 1600)
  end
end)




--[[Esconder Magias Laranjas da tela]]--
TH = macro(100, "esconder msg laranja", function() end)
onStaticText(function(thing, text)
    if TH.isOff() then return end
    if not text:find('says:') then
        g_map.cleanTexts()
    end
end)


--[[esconder MAGIAS(SPRITES)]]--
sprh = macro(100, "esconder sprite", function() end)
onAddThing(function(tile, thing)
    if sprh.isOff() then return end
    if thing:isEffect() then
        thing:hide()
    end
end)

followName = "autofollow"
if not storage[followName] then storage[followName] = { player = 'name'} end
local toFollowPos = {}

UI.Separator()
UI.Label("Auto Follow")

followTE = UI.TextEdit(storage[followName].player or "name", function(widget, newText)
    storage[followName].player = newText
end)

local followMacro = macro(20, "Follow", function()
    local target = getCreatureByName(storage[followName].player)
    if target then
        local tpos = target:getPosition()
        toFollowPos[tpos.z] = tpos
    end
    if player:isWalking() then
        return
    end
    local p = toFollowPos[posz()]
    if not p then
        return
    end
    if autoWalk(p, 20, { ignoreNonPathable = true, precision = 1 }) then
        delay(100)
    end
end)
UI.Separator()

onPlayerPositionChange(function(newPos, oldPos)
  if (g_game.isFollowing()) then
    tfollow = g_game.getFollowingCreature()

    if tfollow then
      if tfollow:getName() ~= storage[followName].player then
        followTE:setText(tfollow:getName())
        storage[followName].player = tfollow:getName()
      end
    end
  end
end)

onCreaturePositionChange(function(creature, newPos, oldPos)
    if creature:getName() == storage[followName].player and newPos then
        toFollowPos[newPos.z] = newPos
    end
end)

macro(70, "Follow Normal",  function()
    if g_game.isFollowing() then
        return
    end
    for _, followcreature in ipairs(g_map.getSpectators(pos(), false)) do
        if (followcreature:getName() == storage[followName].player and getDistanceBetween(pos(), followcreature:getPosition()) <= 8) then
            g_game.follow(followcreature)
        end
    end
end) 
