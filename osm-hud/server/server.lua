QBCore = nil
TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)



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

ResetStress = false

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
		TriggerClientEvent("hud:client:UpdateStress", src, newStress)
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
        TriggerClientEvent("hud:client:UpdateStress", src, newStress)
        TriggerClientEvent('QBCore:Notify', src, 'Increased stress', 'primary', 1500)
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
        TriggerClientEvent("hud:client:UpdateStress", src, newStress)
        TriggerClientEvent('QBCore:Notify', src, 'Decreased stress')
	end
end)



QBCore.Commands.Add("incstress", "Check je cash", {}, false, function(source, args)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)

    Player.Functions.SetMetaData("stress", 70)
    
end)
