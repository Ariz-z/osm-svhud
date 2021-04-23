QBCore = nil

isLoggedIn = true

local Hunger = 100
local Thirst = 100
local Stress = 0

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        if QBCore == nil then
            TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
            Citizen.Wait(200)
        end
    end
end)

RegisterNetEvent("QBCore:Client:OnPlayerUnload")
AddEventHandler("QBCore:Client:OnPlayerUnload", function()
    isLoggedIn = false
    toghud = false
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
end)

RegisterNetEvent('hud:client:UpdateStress')
AddEventHandler('hud:client:UpdateStress', function(newStress)
    Stress = newStress
end)

RegisterNetEvent("hud:client:UpdateNeeds")
AddEventHandler("hud:client:UpdateNeeds", function(newHunger, newThirst)
    Hunger = newHunger
    Thirst = newThirst
end)

Citizen.CreateThread(function()
while true do
	Citizen.Wait(550)
		if QBCore ~= nil and isLoggedIn then 
			SendNUIMessage({
			    action = "updateStatusHud",
			    show = getShowHud(),
			    hunger = Hunger,
			    thirst = Thirst,
			    stress = Stress,
			    armour = GetPedArmour(PlayerPedId()),
			    health = GetEntityHealth(PlayerPedId()) - 100,
			    oxygen = GetPlayerUnderwaterTimeRemaining(PlayerId()) * 4,
			 })
		end

	end
end)


local toghud = true

function getShowHud()
  if IsScreenFadedOut() then
    lastFadeOutDetection = GetGameTimer()
  end

  return toghud and GetGameTimer() > lastFadeOutDetection + 2000
end

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


AddEventHandler("osm-gameplay:enteredVehicle", function()
	SendNUIMessage({action = "hudCarPos"})
end)

AddEventHandler("osm-gameplay:exitVehicle", function()
	SendNUIMessage({action = "regularPos"})
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
