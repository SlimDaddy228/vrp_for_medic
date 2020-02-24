
local function LoadModel(model)
	while not HasModelLoaded(model) do
		RequestModel(model)
		Citizen.Wait(10)
	end
end

local function LoadAnim(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Citizen.Wait(10)
	end
end
local function drawTxt(text,font,centre,x,y,scale,r,g,b,a)
	SetTextFont(6)
	SetTextProportional(6)
	SetTextScale(scale/1.0, scale/1.0)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(centre)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x , y)
end

local function lech(wheelchairObject)
	LoadAnim("anim@gangops@morgue@table@")
	AttachEntityToEntity(PlayerPedId(), wheelchairObject, 0, -0.06, 0.1, 1.3, 0.0, 0.0, 179.0, 0.0, false, false, false, false, 2, true)
	while IsEntityAttachedToEntity(PlayerPedId(), wheelchairObject) do
		Citizen.Wait(10)
		if not IsEntityPlayingAnim(PlayerPedId(), 'anim@gangops@morgue@table@', 'ko_front', 3) then
			TaskPlayAnim(PlayerPedId(), 'anim@gangops@morgue@table@', 'ko_front', 8.0, 8.0, -1, 69, 1, false, false, false)
		end
			if IsControlJustPressed(0, 73) then
				DetachEntity(wheelchairObject, true, true)
				ClearPedTasks(PlayerPedId())
		end
	end
end

local function pickup(wheelchairObject)
	NetworkRequestControlOfEntity(wheelchairObject)
	LoadAnim("anim@mp_ferris_wheel")
	AttachEntityToEntity(wheelchairObject, GetPlayerPed(-1), GetPlayerPed(-1), 0.0, 1.8, -0.40 , 180.0, 180.0, 180.0, 0.0, false, false, true, false, 2, true)
	while IsEntityAttachedToEntity(wheelchairObject, PlayerPedId()) do
		Citizen.Wait(10)
		if not IsEntityPlayingAnim(PlayerPedId(), 'anim@mp_ferris_wheel', 'idle_a_player_one', 3) then
			TaskPlayAnim(PlayerPedId(), 'anim@mp_ferris_wheel', 'idle_a_player_one', 8.0, 8.0, -1, 50, 0, false, false, false)
		end
		if IsControlJustPressed(0, 73) then
			DetachEntity(wheelchairObject, true, true)
			ClearPedTasks(PlayerPedId())
		end
	end
end


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		local ped = PlayerPedId()
		local pedCoords = GetEntityCoords(ped)
		local closestObject = GetClosestObjectOfType(pedCoords, 3.0, GetHashKey("v_med_bed1"), false)
		if DoesEntityExist(closestObject) then
			local wheelChairCoords = GetEntityCoords(closestObject)
			local pickupCoords = wheelChairCoords
			if GetDistanceBetweenCoords(pedCoords, pickupCoords, true) <= 1.5 then
				drawTxt("~g~E~s~ взять ~o~G~s~ лечь ~r~X~w~ отпустить",0,1,0.5,0.95,0.6,255,255,255,255)
				if IsControlJustPressed(0, 38) then
					pickup(closestObject)
				end
				if IsControlJustPressed(0, 47) then
					lech(closestObject)
				end
			end
		end
	end
end)




RegisterNetEvent('spawnkatalka')
AddEventHandler('spawnkatalka', function()
	LoadModel('v_med_bed1')
	local wheelchair = CreateObject(GetHashKey('v_med_bed1'), GetEntityCoords(PlayerPedId())-1, true)
end)

RegisterNetEvent('deletekatalka')
AddEventHandler('deletekatalka', function()
	local wheelchair = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), 10.0, GetHashKey('v_med_bed1'))
	if DoesEntityExist(wheelchair) then
		DeleteEntity(wheelchair)
	end
end)
