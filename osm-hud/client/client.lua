QBCore = nil

Citizen.CreateThread(function() 
    while true do
        Citizen.Wait(10)
        if QBCore == nil then
            TriggerEvent("QBCore:GetObject", function(obj) QBCore = obj end)    
            Citizen.Wait(200)
        end
        if QBCore ~= nil then
            return
        end
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
end)

local toghud = true

local lastFadeOutDetection = 0

function getShowHud()
  if IsScreenFadedOut() then
    lastFadeOutDetection = GetGameTimer()
  end

  return toghud and GetGameTimer() > lastFadeOutDetection + 2000
end

RegisterNetEvent("QBCore:player:onLogout")
AddEventHandler("QBCore:player:onLogout", function()
    ShowHud = false
end)

RegisterCommand('hud', function(source, args, rawCommand)
    if toghud then
        toghud = false
    else
        toghud = true
    end

	SendNUIMessage({
		action = "updateStatusHud",
		show = getShowHud()
	})
end)

RegisterNetEvent('hud:client:UpdateStress')
AddEventHandler('hud:client:UpdateStress', function(newStress)
    stress = newStress
end)

Citizen.CreateThread(function()
	while true do
	Citizen.Wait(1000)
		if isLoggedIn then 
			QBCore.Functions.GetPlayerData(function(PlayerData)
				if PlayerData then
					hunger = PlayerData.metadata["hunger"]
					thirst = PlayerData.metadata["thirst"]
					stress = PlayerData.metadata["stress"]
				end
			end)
		end
	end
end)

RegisterNetEvent('hud:client:UpdateStress')
AddEventHandler('hud:client:UpdateStress', function(newStress)
    stress = newStress
end)

RegisterNetEvent('hud:toggleui')
AddEventHandler('hud:toggleui', function(show)
    if show == true then
        toghud = true
    else
        toghud = false
    end

	SendNUIMessage({
		action = "updateStatusHud",
		show = getShowHud()
	})
end)

local pauseMenu = false


Citizen.CreateThread(function()
    while true do
		if IsPauseMenuActive() and not pauseMenu then
			pauseMenu = true
			toghud = false
			SendNUIMessage({
				action = "updateStatusHud",
				show = false
			})
		elseif not IsPauseMenuActive() and pauseMenu then
			pauseMenu = false
			toghud = true
			SendNUIMessage({
				action = "updateStatusHud",
				show = getShowHud()
			})
		end


        if toghud == true then
            if (not IsPedInAnyVehicle(PlayerPedId(), false) )then
                DisplayRadar(0)
            else
                DisplayRadar(1)
            end
        else
            DisplayRadar(0)
        end

        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
	while true do
                SendNUIMessage({
                    action = "updateStatusHud",
                    show = getShowHud(),
                    hunger = hunger,
                    thirst = thirst,
                    stress = stress,
					armour = GetPedArmour(PlayerPedId()),
					health = GetEntityHealth(PlayerPedId()) - 100,
					oxygen = GetPlayerUnderwaterTimeRemaining(PlayerId()) * 4,
                    })
        Citizen.Wait(1000)
	end
end)

-- AddEventHandler("playerSpawned", function()
-- 	SendNUIMessage({
-- 		action = 'updateStatusHud',
-- 		show = getShowHud(),
-- 		health = GetEntityHealth(PlayerPedId()) - 100
-- 	})

-- 	SendNUIMessage({
-- 		action = 'updateStatusHud',
-- 		show = getShowHud(),
-- 		armour = GetPedArmour(PlayerPedId())
-- 	})
-- end)

local stats = {
	playerHealth = 0,
	playerArmor = 0,
	playerOxygen = 0,
	inVehicle = false,
	enteringVehicle = false
}

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(1800)
		local ped = PlayerPedId()

		if IsPedInAnyVehicle(ped, false) then
			if not stats.inVehicle then
				stats.inVehicle = true
				stats.enteringVehicle = false

				TriggerEvent("osm-gameplay:enteredVehicle")

				local v = GetVehiclePedIsIn(ped)

				Citizen.CreateThread(function()
					while stats.inVehicle do
						local player = PlayerPedId()
						local vehicle = GetVehiclePedIsIn(player)

						SetPlayerCanDoDriveBy(PlayerId(), true)

						if GetVehicleEngineHealth(vehicle) <= 0 then
							SetVehicleUndriveable(vehicle, true)
						else
							SetVehicleUndriveable(vehicle, false)
						end

						if GetPedInVehicleSeat(vehicle, -1) == player then
							if IsEntityInAir(vehicle) then
								local model = GetEntityModel(vehicle)
								if not IsThisModelABoat(model) and not IsThisModelAHeli(model) and not IsThisModelAPlane(model) and not IsThisModelABike(model) and not IsThisModelABicycle(model) then
									DisableControlAction(0, 59)
									DisableControlAction(0, 60)
								end
							end
						end

						Citizen.Wait(0)
					end
				end)
			end
		else
			if stats.inVehicle then
				TriggerEvent("osm-gameplay:exitVehicle")
			end
			stats.inVehicle = false
		end
	end
end)
--[[
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)

		local ped = PlayerPedId()
		local health = GetEntityHealth(ped)
		local armor = GetPedArmour(ped)
		local oxygen = GetPlayerUnderwaterTimeRemaining(PlayerId()) * 4

		if health ~= stats.playerHealth then
			stats.playerHealth = health
			TriggerEvent("osm-gameplay:statUpdate", "health", stats.playerHealth)
		end

		if armor ~= stats.playerArmor then
			stats.playerArmor = armor
			TriggerEvent("osm-gameplay:statUpdate", "armor", stats.playerArmor)
			if maySave then
				TriggerServerEvent("osm-gameplay:setServerArmor", stats.playerArmor)
			end
		end

		if oxygen ~= stats.playerOxygen then
			stats.playerOxygen = oxygen
			if IsPedSwimmingUnderWater(PlayerPedId()) then
				TriggerEvent("osm-gameplay:statUpdate", "oxygen", stats.playerOxygen)
			else
				TriggerEvent("osm-gameplay:statUpdate", "oxygen", 0)
			end
		end

		if IsPedBeingStunned(ped) then
			SetPedMinGroundTimeForStungun(ped, timer)
			SetPedCanRagdoll(ped, true)
		end
	end
end)
]]--
AddEventHandler("osm-gameplay:enteredVehicle", function()
	SendNUIMessage({action = "hudCarPos"})
end)

AddEventHandler("osm-gameplay:exitVehicle", function()
	SendNUIMessage({action = "regularPos"})
end)

AddEventHandler("osm-gameplay:statUpdate", function(name, value)
	if name == "health" then
        SendNUIMessage({
            action = 'updateStatusHud',
            show = getShowHud(),
            health = value - 100
        })
	elseif name == "armor" then
        SendNUIMessage({
            action = 'updateStatusHud',
            show = getShowHud(),
            armour = value
        })
	elseif name == "oxygen" then
        SendNUIMessage({
            action = 'updateStatusHud',
            show = getShowHud(),
            oxygen = value
        })
	end
end)

RegisterNetEvent('qb-hud:client:ProximityActive')
AddEventHandler('qb-hud:client:ProximityActive', function(active)
	
	SendNUIMessage({
		action = 'voicestate',
		state = active
    })
end)


AddEventHandler("osm-carhud:carData", function(data)
	SendNUIMessage({
		action = 'updateStatusHud',
		show = getShowHud(),
		mph = data.mph,
		gas = data.gas,
		nos = data.nos
	})
end)

AddEventHandler("osm-carhud:engineStatus", function(status)
	SendNUIMessage({
		action = 'toggleCarHud',
		toggle = status,
	})
end)

AddEventHandler("osm-ui:adjust", function(field, value)
	SendNUIMessage({
		action = 'adjust',
		field = field,
		value = value
	})
end)

AddEventHandler("osmhealthui:saveToServer", function()
	SendNUIMessage({action = 'postvalues'})
end)

RegisterNUICallback('postValues', function(data, cb)
    TriggerServerEvent("osmhealthui:save", data)
    cb('ok')
end)

-- AddEventHandler("osm-userinterface:queryFromServer", function()
-- 	QBCore.Functions.TriggerCallback("osmhealthui:getOffsets", function(data)
-- 		SendNUIMessage({action = 'readvalues', values = data})
-- 	end)
-- end)