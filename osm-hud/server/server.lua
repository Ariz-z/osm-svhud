QBCore = nil
TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

RegisterServerEvent('osmhealthui:save')
AddEventHandler('osmhealthui:save', function(data)
    MySQL.Async.execute('UPDATE hud SET data = @data', {
		['@data'] = json.encode(data)
	})
end)

QBCore.Functions.CreateCallback('osmhealthui:getOffsets', function(source, cb)
    MySQL.Async.fetchAll('SELECT * FROM hud', {}, function(result)
        if result ~= nil then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

QBCore.Commands.Add("cash", "Check je cash", {}, false, function(source, args)
	local src = source
	local xPlayer = QBCore.Functions.GetPlayer(src)
	TriggerClientEvent('hud:client:ShowMoney', source, xPlayer['PlayerData']['money']['cash'])
end)

QBCore.Commands.Add("cash", "Money in Cash", {}, false, function(source, args)
    TriggerClientEvent('hud:client:ShowMoney', source, "cash")
end)

QBCore.Commands.Add("bank", "Money in Bank", {}, false, function(source, args)
    TriggerClientEvent('hud:client:ShowMoneyBank', source, "bank")
end)

RegisterServerEvent("qb-hud:Server:UpdateStress")
AddEventHandler('qb-hud:Server:UpdateStress', function(StressGain)

	local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local newStress
    if Player ~= nil then
        if not ResetStress then
            if Player.PlayerData.metadata["stress"] == nil then
                Player.PlayerData.metadata["stress"] = 0
            end
            newStress = Player.PlayerData.metadata["stress"] + StressGain
            if newStress <= 0 then newStress = 0 end
        else
            newStress = 0
        end
        if newStress > 100 then
            newStress = 100
        end
        Player.Functions.SetMetaData("stress", newStress)
		-- TriggerClientEvent("hud:client:UpdateStress", src, newStress)
	end
end)

RegisterServerEvent("qb-hud:Server:UpdateNeeds")
AddEventHandler('qb-hud:Server:UpdateNeeds', function(Gain)

	local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local newHunger

    if Player ~= nil then

        newHunger =  Player.PlayerData.metadata["hunger"] - Gain
        newThirst =  Player.PlayerData.metadata["thirst"] - Gain

        Player.Functions.SetMetaData("hunger", newHunger)
        Player.Functions.SetMetaData("thirst", newThirst)

	end
end)

RegisterServerEvent('qb-hud:Server:GainStress')
AddEventHandler('qb-hud:Server:GainStress', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local newStress
    if Player ~= nil then
        if not ResetStress then
            if Player.PlayerData.metadata["stress"] == nil then
                Player.PlayerData.metadata["stress"] = 0
            end
            newStress = Player.PlayerData.metadata["stress"] + amount
            if newStress <= 0 then newStress = 0 end
        else
            newStress = 0
        end
        if newStress > 100 then
            newStress = 100
        end
        Player.Functions.SetMetaData("stress", newStress)
     --   TriggerClientEvent("qb-hud:client:update:stress", src, newStress)
        TriggerClientEvent('QBCore:Notify', src, 'Stress gekregen', 'primary', 1500)
	end
end)

RegisterServerEvent('qb-hud:Server:RelieveStress')
AddEventHandler('qb-hud:Server:RelieveStress', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local newStress
    if Player ~= nil then
        if not ResetStress then
            if Player.PlayerData.metadata["stress"] == nil then
                Player.PlayerData.metadata["stress"] = 0
            end
            newStress = Player.PlayerData.metadata["stress"] - amount
            if newStress <= 0 then newStress = 0 end
        else
            newStress = 0
        end
        if newStress > 100 then
            newStress = 100
        end
        Player.Functions.SetMetaData("stress", newStress)
        TriggerClientEvent("qb-hud:client:update:stress", src, newStress)
        TriggerClientEvent('QBCore:Notify', src, 'Stress Relieved')
	end
end)

QBCore.Functions.CreateCallback('QBCore:HasMoney', function(source, cb, count)
	local retval = false
	local Player = QBCore.Functions.GetPlayer(source)
	if Player ~= nil then 
		if Player.Functions.RemoveMoney('cash', count, true) == true then
			retval = true
		end
	end
	
	cb(retval)
end)

QBCore.Commands.Add("incstress", "Check je cash", {}, false, function(source, args)
	local src = source
	local xPlayer = QBCore.Functions.GetPlayer(src)

    Player.Functions.SetMetaData("stress", 70)
    
end)
