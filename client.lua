
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

local function lech(wheelchairObject)
	LoadAnim("missfinale_c2leadinoutfin_c_int")
	AttachEntityToEntity(PlayerPedId(), wheelchairObject, 0, 0, 0.0, 0.4, 0.0, 0.0, 180.0, 0.0, false, false, false, false, 2, true)
	while IsEntityAttachedToEntity(PlayerPedId(), wheelchairObject) do
		Citizen.Wait(10)
		if not IsEntityPlayingAnim(PlayerPedId(), 'missfinale_c2leadinoutfin_c_int', '_leadin_loop2_lester', 3) then
			TaskPlayAnim(PlayerPedId(), 'missfinale_c2leadinoutfin_c_int', '_leadin_loop2_lester', 8.0, 8.0, -1, 69, 1, false, false, false)
		end
			if IsControlJustPressed(0, 73) then
				DetachEntity(wheelchairObject, true, true)
				ClearPedTasks(PlayerPedId())
		end
	end
end

local function pickup(wheelchairObject)
	NetworkRequestControlOfEntity(wheelchairObject)
	LoadAnim("anim@heists@box_carry@")
	AttachEntityToEntity(wheelchairObject, PlayerPedId(), GetPedBoneIndex(PlayerPedId(),  28422), -0.00, -0.3, -0.73, 195.0, 180.0, 180.0, 0.0, false, false, true, false, 2, true)
	while IsEntityAttachedToEntity(wheelchairObject, PlayerPedId()) do
		Citizen.Wait(5)
		if not IsEntityPlayingAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 3) then
			TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 8.0, 8.0, -1, 50, 0, false, false, false)
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
		local pedCoords = GetEntityCoords(PlayerPedId())
		local closestObject = GetClosestObjectOfType(pedCoords, 10.0, GetHashKey("prop_wheelchair_01"), false)
		local wheelChairCoords = GetEntityCoords(closestObject)
			if GetDistanceBetweenCoords(pedCoords, wheelChairCoords, true) <= 1.5 then
				drawTxt("~g~E~s~ взять ~o~G~s~ сесть ~r~X~w~ отпустить",0,1,0.5,0.95,0.6,255,255,255,255)
				if IsControlJustPressed(0, 38) then
					pickup(closestObject)
				end
				if IsControlJustPressed(0, 47) then
					lech(closestObject)
				end
			end
		end
end)



RegisterNetEvent("spawnkolycka")
AddEventHandler("spawnkolycka", function()
	LoadModel('prop_wheelchair_01')

	local wheelchair = CreateObject(GetHashKey('prop_wheelchair_01'), GetEntityCoords(PlayerPedId()), true)
end, false)

RegisterNetEvent("deletekolycka")
AddEventHandler("deletekolycka", function()
	local wheelchair = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), 10.0, GetHashKey('prop_wheelchair_01'))

	if DoesEntityExist(wheelchair) then
		DeleteEntity(wheelchair)
	end
end, false)
