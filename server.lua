local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")

local function ch_spawn_strecher(player,choice)
  TriggerClientEvent("vrp_for_medic:stretcher:spawn", player)
end

local function ch_delete_strecher(player,choice)
  TriggerClientEvent("vrp_for_medic:stretcher:delete", player)
end

local function ch_spawn_wheelchair(player,choice)
  TriggerClientEvent("vrp_for_medic:wheelchair:spawn",player)
end

local function ch_delete_wheelchair(player,choice)
  TriggerClientEvent("vrp_for_medic:wheelchair:delete",player)
end

vRP.registerMenuBuilder("main", function(add, data)
  local user_id = vRP.getUserId(data.player)
  if user_id then
    local choices = {}

    -- build ems menu
    choices["Медики"] = {function(player,choice)
      local menu  = vRP.buildMenu("ems", {player = player})
      menu.name = "Медики"
      menu.css={top="75px",header_color="#9167dd"}
      menu.onclose = function(player) vRP.openMainMenu(player) end -- onclose event and open main menu

      if vRP.hasPermission(user_id,"player.list") then
        menu["Каталка"] = {ch_spawn_strecher, "Заспавнить каталку"}
      end
      if vRP.hasPermission(user_id, "player.list") then
        menu["Удалить каталку"] = {ch_delete_strecher, "Удалить каталку"}
      end
      if vRP.hasPermission(user_id, "player.list") then
        menu["Инвалидное кресло"] = {ch_spawn_wheelchair, "Заспавнить кресло"}
      end
      if vRP.hasPermission(user_id, "player.list") then
        menu["Удалить кресло"] = {ch_delete_wheelchair, "Удалить кресло"}
      end

      vRP.openMenu(player,menu)
    end}

    add(choices)
  end
end)