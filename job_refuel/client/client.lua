-- TODO add to Config
local EnableBlips = true
local RefuelJobLocationVector = {['x'] = 582.14,  ['y'] = -2722.71,  ['z'] = 6.19}
local isNearJob = true
local isWorkingRefillJob = false
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

-- Create blips
Citizen.CreateThread(function()
	if not EnableBlips then return end
        -- add Vector to Config
        local RefuelJobLocation = AddBlipForCoord(582.14, -2722.71, 6.19)
		SetBlipSprite(RefuelJobLocation, 541)
		SetBlipDisplay(RefuelJobLocation, 4)
		SetBlipScale(RefuelJobLocation, 0.9)
		SetBlipColour(RefuelJobLocation, 3)
		SetBlipAsShortRange(RefuelJobLocation, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('Refuel Job')
		EndTextCommandSetBlipName(RefuelJobLocation)
end)



-- Activate menu when player is inside marker, and draw markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)

		local coords = GetEntityCoords(PlayerPedId())
		isInMarker = false

		for i=1, #Config.RefuelJobLocation, 1 do
			local distance = GetDistanceBetweenCoords(coords, Config.RefuelJobLocation[i], true)

			if distance < Config.DrawDistance then
				DrawMarker(Config.MarkerType, Config.RefuelJobLocation[i], 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.ZoneSize.x, Config.ZoneSize.y, Config.ZoneSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
			end

			if distance < (Config.ZoneSize.x / 2) then
				isInMarker = true
                -- TODO figure out non ESX approach
				ESX.ShowHelpNotification('press ~INPUT_PICKUP~ to start job')
                
                -- Start Job
                if IsControlJustReleased(0, 38) then
                    -- Start Job
                    isWorkingRefillJob = true
                    -- spawnVehicles("tanker", Config.TrailerZone)
                    -- spawnVehicles("hauler", Config.TruckZone)
                end
			end
		end

        -- I don't think this does anything, might be need for future functionality (Copy and Paste master)
		if isInMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			-- TriggerEvent('esx_joblisting:hasExitedMarker')
		end
	end
end)

--- is working Thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        
        if isWorkingRefillJob then
            local coords = GetEntityCoords(PlayerPedId())
            isInMarker = false

            for i=1, #Config.TruckJobZone, 1 do
 
                local distance = GetDistanceBetweenCoords(coords, Config.TruckJobZone[i], true)

                if distance < Config.TruckDrawDistance then
                    print("Hello!")
                    DrawMarker(Config.MarkerType, Config.TruckJobZone[i], 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.ZoneSize.x, Config.ZoneSize.y, Config.ZoneSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
                end

                if distance < (Config.ZoneSize.x / 2) then
                    isInMarker = true
                    -- TODO figure out non ESX approach
                    ESX.ShowHelpNotification('press ~INPUT_PICKUP~ to start job')
                    
                    -- Start Job
                    if IsControlJustReleased(0, 38) then
                        -- Start Job
                        spawnWorkTruck()
                        spawnVehicles("tanker", Config.TrailerZone)
                    end
                end 
                
            end

            -- I don't think this does anything, might be need for future functionality (Copy and Paste master)
            if isInMarker and not hasAlreadyEnteredMarker then
                hasAlreadyEnteredMarker = true
            end
    
            if not isInMarker and hasAlreadyEnteredMarker then
                hasAlreadyEnteredMarker = false
            end
        
        end

    end


end)


function spawnWorkTruck()
    local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 8.0, 0.5))
    local vehicleName = "hauler"
    vehiclehash = GetHashKey(vehicleName)
    RequestModel(vehiclehash)

    Citizen.CreateThread(function() 
            local waiting = 0
            while not HasModelLoaded(vehiclehash) do
                waiting = waiting + 100
                Citizen.Wait(100)
                if waiting > 5000 then
                    ShowNotification("~r~Could not load the vehicle model in time, a crash was prevented.")
                    break
                end
            end
            vehicle = CreateVehicle(vehiclehash, Config.TruckZone.x, Config.TruckZone.y, Config.TruckZone.z, GetEntityHeading(PlayerPedId())+90, 1, 0)
            SetPedIntoVehicle(PlayerPedId(), vehicle,-1)
        end)
end

function spawnVehicles(vehicle, location)
    -- Check if location is empty 
    ESX.Game.SpawnLocalVehicle(vehicle, location, 100, function(vehicle) 
    end)
end


-- Pick Gas Station location for first job
-- Set GPS
-- Create action when getting to gas station
-- Pay Employee
-- Loop, 
-- Fix Posistion of Trailer
-- Check if Job is active
-- Only allow one job at a time?
-- Make sure nothing in where the Trailer needs to spawn.

-- Update gas stations to need gas???