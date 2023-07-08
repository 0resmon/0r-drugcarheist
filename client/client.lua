ESX = nil
local carHeistBlip = nil
local deliveryBlip = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(5)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
    TriggerServerEvent('0r:loadedPlayer')
end)

AddEventHandler('onResourceStart', function(resourceName)
	if (GetCurrentResourceName() == resourceName) then
		TriggerServerEvent('0r:loadedPlayer')
	end
end)



function ShowNotification(msg)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(msg)
	DrawNotification(0,1)
end

RegisterNetEvent('0r:StartCarHeist')
AddEventHandler('0r:StartCarHeist', function()
    ShowNotification("Go to the Car Heist Location blip on the map, steal the cars, and bring them back to me again.") 
    TriggerEvent('toggleCarHeistBlips')
    TriggerEvent('0r-heistpack:npcspawn')
    SpawnHeistCar1()
    TriggerEvent('ScriptFinish')
end)

RegisterNetEvent('0r-heistpack:npcspawn')
AddEventHandler('0r-heistpack:npcspawn', function()

    local npcSpawnPoints = {
        vector4(1745.097, 3291.632, 41.103, 206.41),
        vector4(1737.483, 3293.477, 41.163, 206.41),
        vector4(1730.833, 3297.285, 41.223, 206.41),
        vector4(1738.119, 3286.475, 41.135, 206.41),
        vector4(1723.602, 3303.942, 41.223, 206.41),
        vector4(1737.484, 3310.934, 41.223, 206.41),
        vector4(1737.017, 3324.304, 41.223, 206.41),
        -- vector4(1748.229, 3296.202, 41.140, 206.41),
        -- vector4(1705.895, 3290.302, 45.397, 206.41),
        -- vector4(1740.910, 3302.899, 47.750, 206.41),
        -- vector4(1731.038, 3295.353, 48.745, 206.41),

    }


    function SpawnNPC(coords)
        local hash = GetHashKey("s_m_y_blackops_01") 
        while not HasModelLoaded(hash) do
            RequestModel(hash)
            Citizen.Wait(10)
        end

        AddRelationshipGroup('Attackers')
        SetPedRelationshipGroupHash(PlayerPedId(), GetHashKey('PLAYER'))
        SetRelationshipBetweenGroups(5, GetHashKey("Attackers"), GetHashKey("PLAYER"))
        SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), GetHashKey("Attackers"))

    
        local npc = CreatePed(5, hash, coords, true, true, true)
        GiveWeaponToPed(npc, GetHashKey("WEAPON_PISTOL"), 1000, false, true) 

        SetPedCombatAttributes(npc, 46, true) 
        SetPedCombatAttributes(npc, 0, true)
        SetPedCombatRange(npc, 2) 
        SetPedCombatMovement(npc, 3)
        SetCanAttackFriendly(npc, false, false)
        SetPedRelationshipGroupHash(npc, GetHashKey('Attackers'))
        SetModelAsNoLongerNeeded(hash)

 
        Citizen.CreateThread(function()
            while true do
                Citizen.Wait(0)
                local playerPed = PlayerPedId()
                local npcCoords = GetEntityCoords(npc)
                local playerCoords = GetEntityCoords(playerPed)
                local distance = GetDistanceBetweenCoords(npcCoords, playerCoords, true)
                if distance <= 40.0 and not IsPedInAnyVehicle(playerPed) then
                    TaskCombatPed(npc, playerPed, 0, 16)
                end
            end
        end)

        Citizen.CreateThread(function()
            while true do
                Citizen.Wait(30000)
                if IsEntityDead(npc) then
                    DeleteEntity(npc)
                    break
                end
            end
        end)
    end

    
    for _, coords in ipairs(npcSpawnPoints) do
        SpawnNPC(coords)
    end
end)







local heistCarSpawn1 = vector3(1728.540, 3313.890, 41.223)


function SpawnHeistCar1()
    local vehicleHash = GetHashKey("benson")
    RequestModel(vehicleHash)
    while not HasModelLoaded(vehicleHash) do
        Citizen.Wait(10)
    end
    local vehicle = CreateVehicle(vehicleHash, heistCarSpawn1, 0.0, true, false)
    SetVehicleDoorsLocked(vehicle, 2) 
    SetVehicleFuelLevel(vehicle, 100.0)
end




RegisterNetEvent('0r:carheisttorchkit')
AddEventHandler('0r:carheisttorchkit', function()
	local playerPed = PlayerPedId()
	local coords    = GetEntityCoords(playerPed)

	if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
		local vehicle

		if IsPedInAnyVehicle(playerPed, false) then
			vehicle = GetVehiclePedIsIn(playerPed, false)
		else
			vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
		end

		local chance = math.random(100)
		local alarm  = math.random(100)

		if DoesEntityExist(vehicle) then
			if alarm <= 33 then
				SetVehicleAlarm(vehicle, true)
				StartVehicleAlarm(vehicle)
			end

			TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)

			Citizen.CreateThread(function()
				Citizen.Wait(10000)
				if chance <= 100 then
					SetVehicleDoorsLocked(vehicle, 1)
					SetVehicleDoorsLockedForAllPlayers(vehicle, false)
					ClearPedTasksImmediately(playerPed)
                    ShowNotification("You have successfully unlocked it. Take Car to Delivery Locations") 
					ClearPedTasksImmediately(playerPed)
                    TriggerEvent('ScriptFinish')
                    Citizen.Wait(20000) 
                    TriggerEvent('startBallerAttack')
				end
			end)
		end
	end
end)





RegisterNetEvent('startBallerAttack')
AddEventHandler('startBallerAttack', function()
    local playerPed = PlayerPedId()
    local vehicleModel = "baller" 
    local npcModel = "s_m_y_blackops_01" 
    local npcWeapon = "WEAPON_PISTOL" 
    local maxAttempts = 4 
    local spawnDistance = -15.0 
    local distanceThreshold = 70.0 

    RequestModel(vehicleModel)
    RequestModel(npcModel)

    while not HasModelLoaded(vehicleModel) or not HasModelLoaded(npcModel) do
        Wait(1)
    end

    local attempts = 0
    while attempts < maxAttempts do
        local spawnCoords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, spawnDistance, 0.0)
        local vehicle = CreateVehicle(GetHashKey(vehicleModel), spawnCoords, GetEntityHeading(playerPed), true, false)
        local npcPed = CreatePedInsideVehicle(vehicle, 26, npcModel, -1, true, false)

        GiveWeaponToPed(npcPed, GetHashKey(npcWeapon), 250, false, true)

        SetPedShootRate(npcPed, 1000)

        SetPedCombatAttributes(npcPed, 46, true)
        SetPedCombatAttributes(npcPed, 0, true)
        SetPedCombatRange(npcPed, 2)
        SetPedCombatMovement(npcPed, 3)
        SetPedAccuracy(npcPed, 100)

        TaskVehicleDriveWander(npcPed, vehicle, 20.0, 786603)

        TaskCombatPed(npcPed, playerPed, 0, 16)

        while true do
            Citizen.Wait(0)
            local playerCoords = GetEntityCoords(playerPed)
            local npcCoords = GetEntityCoords(npcPed)
            local distance = GetDistanceBetweenCoords(playerCoords, npcCoords, true)
            
            if IsEntityDead(npcPed) or not DoesEntityExist(npcPed) or distance > distanceThreshold then
                Citizen.Wait(15000)
                break
            end
        end

        DeletePed(npcPed)
        DeleteVehicle(vehicle)

        attempts = attempts + 1
    end
end)


RegisterNetEvent('startCarScene')
AddEventHandler('startCarScene', function(source, args)
local ped = PlayerPedId()
    RequestCutscene("fix_low_mcs1", 8)
    while not (HasCutsceneLoaded()) do
        Wait(0)
        RequestCutscene("fix_low_mcs1", 8)
    end

   TriggerEvent('save_all_clothes') 




    SetCutsceneEntityStreamingFlags('MP_1', 0, 1)
    RegisterEntityForCutscene(ped, 'MP_1', 0, 0, 64)

    SetCutsceneEntityStreamingFlags('MP_2', 0, 1)
    RegisterEntityForCutscene(ped, 'MP_2', 0, 0, 64)

    SetCutsceneEntityStreamingFlags('MP_3', 0, 1)
    RegisterEntityForCutscene(ped, 'MP_3', 0, 0, 64)

    SetCutsceneEntityStreamingFlags('MP_4', 0, 1)
    RegisterEntityForCutscene(ped, 'MP_4', 0, 0, 64)

    StartCutscene(0)

   
    while not (DoesCutsceneEntityExist('MP_1', 0)) do
        Wait(0)
    end

   SetCutscenePedComponentVariationFromPed(PlayerPedId(), GetPlayerPed(-1), 1885233650)
   SetPedComponentVariation(GetPlayerPed(-1), 11, jacket_old, jacket_tex, jacket_pal)
   SetPedComponentVariation(GetPlayerPed(-1), 8, shirt_old, shirt_tex, shirt_pal)
   SetPedComponentVariation(GetPlayerPed(-1), 3, arms_old, arms_tex, arms_pal)
   SetPedComponentVariation(GetPlayerPed(-1), 4, pants_old,pants_tex,pants_pal)
   SetPedComponentVariation(GetPlayerPed(-1), 6, feet_old,feet_tex,feet_pal)
   SetPedComponentVariation(GetPlayerPed(-1), 1, mask_old,mask_tex,mask_pal)
   SetPedComponentVariation(GetPlayerPed(-1), 2, hair_old,hair_tex,hair_pal)
   SetPedComponentVariation(GetPlayerPed(-1), 9, vest_old,vest_tex,vest_pal)
   SetPedPropIndex(GetPlayerPed(-1), 0, hat_prop, hat_tex, 0)
   SetPedPropIndex(GetPlayerPed(-1), 1, glass_prop, glass_tex, 0)

    while not (HasCutsceneFinished()) do
        Wait(0)
    end

    TriggerServerEvent("0r:heistparaver")
end)



RegisterNetEvent('save_all_clothes') 
AddEventHandler('save_all_clothes',function()
    local ped = GetPlayerPed(-1)
    mask_old,mask_tex,mask_pal = GetPedDrawableVariation(ped,1),GetPedTextureVariation(ped,1),GetPedPaletteVariation(ped,1)
    vest_old,vest_tex,vest_pal = GetPedDrawableVariation(ped,9),GetPedTextureVariation(ped,9),GetPedPaletteVariation(ped,9)
    glass_prop,glass_tex = GetPedPropIndex(ped,1),GetPedPropTextureIndex(ped,1)
    hat_prop,hat_tex = GetPedPropIndex(ped,0),GetPedPropTextureIndex(ped,0)
    hair_old,hair_tex,hair_pal = GetPedDrawableVariation(ped,2),GetPedTextureVariation(ped,2),GetPedPaletteVariation(ped,2)
    jacket_old,jacket_tex,jacket_pal = GetPedDrawableVariation(ped, 11),GetPedTextureVariation(ped,11),GetPedPaletteVariation(ped,11)
    shirt_old,shirt_tex,shirt_pal = GetPedDrawableVariation(ped,8),GetPedTextureVariation(ped,8),GetPedPaletteVariation(ped,8)
    arms_old,arms_tex,arms_pal = GetPedDrawableVariation(ped,3),GetPedTextureVariation(ped,3),GetPedPaletteVariation(ped,3)
    pants_old,pants_tex,pants_pal = GetPedDrawableVariation(ped,4),GetPedTextureVariation(ped,4),GetPedPaletteVariation(ped,4)
    feet_old,feet_tex,feet_pal = GetPedDrawableVariation(ped,6),GetPedTextureVariation(ped,6),GetPedPaletteVariation(ped,6)
end)



local npcCoords = vector3(615.6168, -409.908, 25.072) 

Citizen.CreateThread(function()
    local npcHash = GetHashKey("cs_nervousron") 

 
    RequestModel(npcHash)
    while not HasModelLoaded(npcHash) do
        Citizen.Wait(10)
    end

    local npcPed = CreatePed(4, npcHash, npcCoords.x, npcCoords.y, npcCoords.z, 0.0, false, true)

 
    SetEntityInvincible(npcPed, true)
    SetPedCanBeTargetted(npcPed, false)
    FreezeEntityPosition(npcPed, true)

    while true do
        Citizen.Wait(0)

        local playerCoords = GetEntityCoords(PlayerPedId()) 
        local npcDistance = #(playerCoords - npcCoords) 

        if npcDistance < 2.0 then 
            DrawText3D(npcCoords.x, npcCoords.y, npcCoords.z + 1.0, "[E] Car Heist") 

            if IsControlJustReleased(0, 38) then 
            
                ESX.TriggerServerCallback('0r:getcooldown', function(cb)
				if not cb then
                TaskStartScenarioInPlace(npcPed, "WORLD_HUMAN_STAND_MOBILE", 0, true)
                Citizen.Wait(5000) 
                ClearPedTasks(npcPed)
                TriggerServerEvent("0r:heisttStart")
                end
                end)
            end
        end
    end
end)


function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())

    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.02 + factor, 0.03, 41, 11, 41, 68)
end

RegisterNetEvent('ScriptFinish')
AddEventHandler('ScriptFinish', function()

local bensonModel = GetHashKey('benson') 
local targetPosition = vector3(605.6551, -415.188, 24.744) 

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        local playerPosition = GetEntityCoords(playerPed)
        
        if IsEntityAVehicle(vehicle) and GetEntityModel(vehicle) == bensonModel then
            -
            if Vdist2(playerPosition.x, playerPosition.y, playerPosition.z, targetPosition.x, targetPosition.y, targetPosition.z) <= 10.0 then
            
               
                DoScreenFadeOut(2000)
                Citizen.Wait(2000)
                DoScreenFadeIn(2000)
                
             
                DeleteEntity(vehicle)
                TriggerEvent('startCarScene')
            end
        end
    end
end)
end)





RegisterNetEvent('toggleCarHeistBlips')
AddEventHandler('toggleCarHeistBlips', function()
    if carHeistBlip and deliveryBlip then
        RemoveBlip(carHeistBlip)
        RemoveBlip(deliveryBlip)
        carHeistBlip = nil
        deliveryBlip = nil
    else
        carHeistBlip = AddBlipForCoord(1716.624, 3328.675, 42.904) 
        SetBlipSprite(carHeistBlip, 1)
        SetBlipDisplay(carHeistBlip, 4)
        SetBlipColour(carHeistBlip, 1)
        SetBlipAsShortRange(carHeistBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Car Heist Location")
        EndTextCommandSetBlipName(carHeistBlip)

        deliveryBlip = AddBlipForCoord(614.6239, -409.182, 26.032)  
        SetBlipSprite(deliveryBlip, 1)
        SetBlipDisplay(deliveryBlip, 4)
        SetBlipColour(deliveryBlip, 1)
        SetBlipAsShortRange(deliveryBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Delivery Location")
        EndTextCommandSetBlipName(deliveryBlip)
    end
end)


















    
    -- RegisterCommand("startcb", function() -- ORDER CREATION
    --     PrepareMusicEvent("FM_INTRO_START") --FM_INTRO_START
    --     TriggerMusicEvent("FM_INTRO_START") --FM_INTRO_START
    --     local plyrId = PlayerPedId() -- PLAYER ID
    --     -----------------------------------------------
    --     if IsMale(plyrId) then
    --         RequestCutsceneWithPlaybackList("MP_INTRO_CONCAT", 31, 8)
    --     else	
    --         RequestCutsceneWithPlaybackList("MP_INTRO_CONCAT", 103, 8)
    --     end
    --     while not HasCutsceneLoaded() do Wait(10) end --- waiting for the cutscene to load
    --     if IsMale(plyrId) then
    --         RegisterEntityForCutscene(0, 'MP_Male_Character', 3, GetEntityModel(PlayerPedId()), 0)
    --         RegisterEntityForCutscene(PlayerPedId(), 'MP_Male_Character', 0, 0, 0)
    --         SetCutsceneEntityStreamingFlags('MP_Male_Character', 0, 1) 
    --         local female = RegisterEntityForCutscene(0,"MP_Female_Character",3,0,64) 
    --         NetworkSetEntityInvisibleToNetwork(female, true)
    --     else
    --         RegisterEntityForCutscene(0, 'MP_Female_Character', 3, GetEntityModel(PlayerPedId()), 0)
    --         RegisterEntityForCutscene(PlayerPedId(), 'MP_Female_Character', 0, 0, 0)
    --         SetCutsceneEntityStreamingFlags('MP_Female_Character', 0, 1) 
    --         local male = RegisterEntityForCutscene(0,"MP_Male_Character",3,0,64) 
    --         NetworkSetEntityInvisibleToNetwork(male, true)
    --     end
    --     local ped = {}
    --     for v_3=0, 6, 1 do
    --         if v_3 == 1 or v_3 == 2 or v_3 == 4 or v_3 == 6 then
    --             ped[v_3] = CreatePed(26, `mp_f_freemode_01`, -1117.77783203125, -1557.6248779296875, 3.3819, 0.0, 0, 0)
    --         else
    --             ped[v_3] = CreatePed(26, `mp_m_freemode_01`, -1117.77783203125, -1557.6248779296875, 3.3819, 0.0, 0, 0)
    --         end
    --         if not IsEntityDead(ped[v_3]) then
    --             sub_b747(ped[v_3], v_3)
    --             FinalizeHeadBlend(ped[v_3])
    --             RegisterEntityForCutscene(ped[v_3], sub_b0b5[v_3], 0, 0, 64)
    --         end
    --     end
        
    --     NewLoadSceneStartSphere(-1212.79, -1673.52, 7, 1000, 0) ----- avoid texture bugs
    --     -----------------------------------------------
    --     SetWeatherTypeNow("EXTRASUNNY") ---- SUN TIME
    --     StartCutscene(4) --- START the custscene
    
    --     Wait(31520) --- custscene time
    --     for v_3=0, 6, 1 do
    --         DeleteEntity(ped[v_3])
    --     end
    --     PrepareMusicEvent("AC_STOP")
    --     TriggerMusicEvent("AC_STOP")
    -- end) 
    
    
    -- function IsMale(ped)
    --     if IsPedModel(ped, 'mp_m_freemode_01') then
    --         return true
    --     else
    --         return false
    --     end
    -- end