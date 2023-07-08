ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local cooldown = {}

RegisterNetEvent('0r:loadedPlayer', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	if cooldown[xPlayer.identifier] == nil then
		cooldown[xPlayer.identifier] = { cooldown = false }
	end
end)


ESX.RegisterServerCallback('0r:getcooldown', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	cb(cooldown[xPlayer.identifier].cooldown)
end)


RegisterServerEvent("0r:heisttStart")
AddEventHandler("0r:heisttStart", function()
    local xPlayer = ESX.GetPlayerFromId(source)
	cooldown[xPlayer.identifier].cooldown = true
	Timer(xPlayer.identifier)
    TriggerClientEvent('0r:StartCarHeist', source)
    xPlayer.addInventoryItem('torchkit', 1)
end)

ESX.RegisterUsableItem('torchkit', function(source)
    local xPlayer  = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('torchkit', 1)
	Citizen.Wait(250)
    TriggerClientEvent('0r:carheisttorchkit', source)
end)

RegisterServerEvent("0r:heistparaver")
AddEventHandler("0r:heistparaver", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem('money', 150000)
end)

function Timer(hex)
	SetTimeout(1 * 60 * 60 * 1000, function()
		cooldown[hex].cooldown = false
	end)
end

