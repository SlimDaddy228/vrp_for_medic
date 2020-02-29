
local function LoadModel(model)
	while not HasModelLoaded(model) do
		RequestModel(model)
		Wait(10)
	end
end

local function LoadAnim(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Wait(10)
	end
end

local function DrawText3Ds(coords, text, scale, color, notRect)
	local x,y,z = coords.x, coords.y, coords.z
	local onScreen, _x, _y = World3dToScreen2d(x, y, z)
	local pX, pY, pZ = table.unpack(GetGameplayCamCoords())

  color = color

  if not color then
    color = {255, 255, 255, 215}
  end

	SetTextScale(scale, scale)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextEntry("STRING")
	SetTextCentre(1)
	SetTextColour(color[1], color[2], color[3], color[4])

	AddTextComponentString(text)
	DrawText(_x, _y)

  if not notRect then
    local factor = (string.len(text)) / 370

    DrawRect(_x, _y + 0.0150, 0.005 + factor, 0.025, 41, 11, 41, 100)
  end
end

local function GoToBed(wheelchairObject)
	local ped = PlayerPedId()
	LoadAnim("anim@gangops@morgue@table@")
	AttachEntityToEntity(ped, wheelchairObject, 0, -0.06, 0.1, 1.3, 0.0, 0.0, 179.0, 0.0, false, false, false, false, 2, true)
	while IsEntityAttachedToEntity(ped, wheelchairObject) do
		Wait(5)
		if not IsEntityPlayingAnim(ped, 'anim@gangops@morgue@table@', 'ko_front', 3) then
			TaskPlayAnim(ped, 'anim@gangops@morgue@table@', 'ko_front', 8.0, 8.0, -1, 69, 1, false, false, false)
		end
		if IsControlJustPressed(0, 73) then
			DetachEntity(wheelchairObject, true, true)
			ClearPedTasks(ped)
		end
	end
end

local function Pickup(wheelchairObject)
	local ped = PlayerPedId()
	NetworkRequestControlOfEntity(wheelchairObject)
	LoadAnim("anim@mp_ferris_wheel")
	AttachEntityToEntity(wheelchairObject, ped, ped, 0.0, 1.8, -0.40 , 180.0, 180.0, 180.0, 0.0, false, false, true, false, 2, true)
	while IsEntityAttachedToEntity(wheelchairObject, ped) do
		Wait(5)
		if not IsEntityPlayingAnim(ped, 'anim@mp_ferris_wheel', 'idle_a_player_one', 3) then
			TaskPlayAnim(ped, 'anim@mp_ferris_wheel', 'idle_a_player_one', 8.0, 8.0, -1, 50, 0, false, false, false)
		end
		if IsControlJustPressed(0, 73) then
			DetachEntity(wheelchairObject, true, true)
			ClearPedTasks(ped)
		end
	end
end

local beds = {
	'v_med_bed1',
	'v_med_bed2',
	'v_med_emptybed',
}

local nearObject, isLocal

Citizen.CreateThread(function()
	while true do
		Wait(1000)
		local pedCoords = GetEntityCoords(PlayerPedId())
		for k,v in pairs(beds) do
			local closestObject = GetClosestObjectOfType(pedCoords, 3.0, GetHashKey(v), false)
			if DoesEntityExist(closestObject) then
				nearObject = closestObject
				isLocal = not NetworkGetEntityIsNetworked(closestObject)
				break
			else
				nearObject = nil
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Wait(5)
    if nearObject then
      
			local wheelChairCoords = GetEntityCoords(nearObject)
			local text = '[~g~E~s~] взять | [~o~G~s~] лечь | [~r~X~w~] встать'

			if isLocal then
				text = '[~o~G~s~] лечь | [~r~X~w~] встать'
			end

      DrawText3Ds(wheelChairCoords, text, 0.5, nil, true)

      if IsControlJustPressed(0, 38) and not isLocal then
        Pickup(nearObject)
      elseif IsControlJustPressed(0, 47) then
        GoToBed(nearObject)
      end

    end
	end
end)

RegisterNetEvent('vrp_for_medic:stretcher:spawn')
AddEventHandler('vrp_for_medic:stretcher:spawn', function()
	LoadModel('v_med_bed1')
	local wheelchair = CreateObject(GetHashKey('v_med_bed1'), GetEntityCoords(PlayerPedId())-1, true, true, true)
end)

RegisterNetEvent('vrp_for_medic:stretcher:delete')
AddEventHandler('vrp_for_medic:stretcher:delete', function()
	local wheelchair = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), 10.0, GetHashKey('v_med_bed1'))
	if DoesEntityExist(wheelchair) then
		DeleteEntity(wheelchair)
	end
end)