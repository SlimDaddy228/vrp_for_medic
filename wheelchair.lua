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

local function Sit(wheelchairObject)
	local ped = PlayerPedId()
	LoadAnim("missfinale_c2leadinoutfin_c_int")
	AttachEntityToEntity(ped, wheelchairObject, 0, 0, 0.0, 0.4, 0.0, 0.0, 180.0, 0.0, false, false, false, false, 2, true)
	while IsEntityAttachedToEntity(ped, wheelchairObject) do
		Wait(5)
		if not IsEntityPlayingAnim(ped, 'missfinale_c2leadinoutfin_c_int', '_leadin_loop2_lester', 3) then
			TaskPlayAnim(ped, 'missfinale_c2leadinoutfin_c_int', '_leadin_loop2_lester', 8.0, 8.0, -1, 69, 1, false, false, false)
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
	LoadAnim("anim@heists@box_carry@")
	AttachEntityToEntity(wheelchairObject, ped, GetPedBoneIndex(ped,  28422), -0.00, -0.3, -0.73, 195.0, 180.0, 180.0, 0.0, false, false, true, false, 2, true)
	while IsEntityAttachedToEntity(wheelchairObject, ped) do
		Wait(5)
		if not IsEntityPlayingAnim(ped, 'anim@heists@box_carry@', 'idle', 3) then
			TaskPlayAnim(ped, 'anim@heists@box_carry@', 'idle', 8.0, 8.0, -1, 50, 0, false, false, false)
		end
		if IsControlJustPressed(0, 73) then
			DetachEntity(wheelchairObject, true, true)
			ClearPedTasks(ped)
		end
	end
end

local nearObject

Citizen.CreateThread(function()
	while true do
		Wait(1000)
		local pedCoords = GetEntityCoords(PlayerPedId())
		local closestObject = GetClosestObjectOfType(pedCoords, 3.0, GetHashKey("prop_wheelchair_01"), false)
    if DoesEntityExist(closestObject) and NetworkGetEntityIsNetworked(closestObject) then
			nearObject = closestObject
		else
			nearObject = nil
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Wait(5)
    if nearObject then
      
      local wheelChairCoords = GetEntityCoords(nearObject)
      DrawText3Ds(wheelChairCoords, "[~g~E~s~] взять | [~o~G~s~] сесть | [~r~X~w~] отпустить", 0.5, nil, true)

      if IsControlJustPressed(0, 38) then
        Pickup(nearObject)
      elseif IsControlJustPressed(0, 47) then
        Sit(nearObject)
      end

    end
	end
end)

RegisterNetEvent('vrp_for_medic:wheelchair:spawn')
AddEventHandler('vrp_for_medic:wheelchair:spawn', function()
	LoadModel('prop_wheelchair_01')

	local wheelchair = CreateObject(GetHashKey('prop_wheelchair_01'), GetEntityCoords(PlayerPedId()), true)
end, false)

RegisterNetEvent('vrp_for_medic:wheelchair:delete')
AddEventHandler('vrp_for_medic:wheelchair:delete', function()
	local wheelchair = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), 10.0, GetHashKey('prop_wheelchair_01'))

	if DoesEntityExist(wheelchair) then
		DeleteEntity(wheelchair)
	end
end, false)
