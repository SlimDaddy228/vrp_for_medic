
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
		
		Wait(10)
	end
end

local function LoadAnim(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		
		Wait(10)
	end
end

local function lech(wheelchairObject)
	local ped = PlayerPedId()
	LoadAnim("missfinale_c2leadinoutfin_c_int")
	AttachEntityToEntity(ped, wheelchairObject, 0, 0, 0.0, 0.4, 0.0, 0.0, 180.0, 0.0, false, false, false, false, 2, true)
	while IsEntityAttachedToEntity(ped, wheelchairObject) do
		Wait(10)
		if not IsEntityPlayingAnim(ped, 'missfinale_c2leadinoutfin_c_int', '_leadin_loop2_lester', 3) then
			TaskPlayAnim(ped, 'missfinale_c2leadinoutfin_c_int', '_leadin_loop2_lester', 8.0, 8.0, -1, 69, 1, false, false, false)
		end
		if IsControlJustPressed(0, 73) then
			Wait(10)
			DetachEntity(wheelchairObject, true, true)
			ClearPedTasks(ped)
		end
	end
end

local function pickup(wheelchairObject)
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
			Wait(20)
			DetachEntity(wheelchairObject, true, true)
			ClearPedTasks(ped)
		end
	end
end

CreateThread(function()
	while true do
		Wait(10)
		local pedCoords = GetEntityCoords(PlayerPedId())
		local closestObject = GetClosestObjectOfType(pedCoords, 10.0, GetHashKey("prop_wheelchair_01"), false)
		local wheelChairCoords = GetEntityCoords(closestObject)
			if GetDistanceBetweenCoords(pedCoords, wheelChairCoords, true) <= 2.5 then
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
