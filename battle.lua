setDefaultTab("Tools")
local ui = setupUI([[
Panel
  height: 100

  BotSwitch
    id: hidePlayers
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    !text: tr('Hide Players')

  BotSwitch
    id: hideNPCs
    anchors.top: hidePlayers.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    !text: tr('Hide NPCs')

  BotSwitch
    id: hideMonsters
    anchors.top: hideNPCs.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    !text: tr('Hide Monsters')

  BotSwitch
    id: hideSkulls
    anchors.top: hideMonsters.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    !text: tr('Hide Non-Skull Players')

  BotSwitch
    id: hideParty
    anchors.top: hideSkulls.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    !text: tr('Hide Party Members')
]])

if not storage.hideFilters then
  storage.hideFilters = {
    players = false,
    npcs = false,
    monsters = false,
    skulls = false,
    party = false,
  }
end

local config = storage.hideFilters

ui.hidePlayers:setOn(config.players)
ui.hidePlayers.onClick = function(widget)
  config.players = not config.players
  widget:setOn(config.players)
  modules.game_battle.checkCreatures()
end

ui.hideNPCs:setOn(config.npcs)
ui.hideNPCs.onClick = function(widget)
  config.npcs = not config.npcs
  widget:setOn(config.npcs)
  modules.game_battle.checkCreatures()
end

ui.hideMonsters:setOn(config.monsters)
ui.hideMonsters.onClick = function(widget)
  config.monsters = not config.monsters
  widget:setOn(config.monsters)
  modules.game_battle.checkCreatures()
end

ui.hideSkulls:setOn(config.skulls)
ui.hideSkulls.onClick = function(widget)
  config.skulls = not config.skulls
  widget:setOn(config.skulls)
  modules.game_battle.checkCreatures()
end

ui.hideParty:setOn(config.party)
ui.hideParty.onClick = function(widget)
  config.party = not config.party
  widget:setOn(config.party)
  modules.game_battle.checkCreatures()
end

local filterPanel = modules.game_battle.filterPanel
modules.game_battle.battleWindow:show()

modules.game_battle.doCreatureFitFilters = function(creature)
  if creature:isLocalPlayer() then
    return false
  end
  if creature:getHealthPercent() <= 0 then
    return false
  end

  local pos = creature:getPosition()
  if not pos then return false end

  local isBotServer = vBot.BotServerMembers[creature:getName()]
  local localPlayer = g_game.getLocalPlayer()
  if pos.z ~= localPlayer:getPosition().z or not creature:canBeSeen() then return false end

  local hidePlayers = config.players
  local hideNPCs = config.npcs
  local hideMonsters = config.monsters
  local hideSkulls = config.skulls
  local hideParty = config.party

  if hidePlayers and creature:isPlayer() then
    return false
  elseif hideNPCs and creature:isNpc() then
    return false
  elseif creature:isMonster() and hideMonsters then
    return false
  elseif hideSkulls and creature:isPlayer() and creature:getSkull() == SkullNone then
    return false
  elseif hideParty  and creature:getShield() == 3  or hideParty  and creature:getEmblem() == 4 or hideParty and creature:getShield() == 7 or hideParty and creature:getShield() == 8 or hideParty and creature:getShield() == 4 or hideParty and creature:getShield() == 5 or hideParty and creature:getShield() == 6 then
    return false

  elseif config.enabled and ((isFriend(creature) or creature:getEmblem() == 1 or creature:getEmblem() == 4 or isBotServer)) then
    return false
  end
  return true
end
